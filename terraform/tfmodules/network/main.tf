terraform {
  required_version = ">= 1.4"
  required_providers {
    oci = {
      source = "oracle-terraform-modules/oci"
      version = ">= 5.0.0"
    }
  }
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

// First, create a VCN, subnet, and internet gateway

resource "oci_core_vcn" "tucsocial_vcn" {
  cidr_block     = var.vcn_cidr_block
  display_name   = "${var.display_name}-vcn"
  dns_label      = var.display_name
  compartment_id = var.compartment_id
}

resource "oci_core_subnet" "tucsocial_public_subnet" {
  cidr_block     = var.public_subnet_cidr_block
  display_name   = "public_${var.display_name}"
  dns_label      = "public"
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.tucsocial_vcn.id
  route_table_id = oci_core_vcn.tucsocial_vcn.default_route_table_id
}

resource "oci_core_subnet" "tucsocial_private_subnet" {
    cidr_block     = var.private_subnet_cidr_block
    display_name   = "private_${var.display_name}"
    dns_label      = "private"
    compartment_id = var.compartment_id
    vcn_id         = oci_core_vcn.tucsocial_vcn.id
    route_table_id = oci_core_vcn.tucsocial_vcn.default_route_table_id
}

// Now we need an internet gateway to connect the public subnet to the internet

resource "oci_core_internet_gateway" "tucsocial_ig" {
    display_name   = "ig_${var.display_name}"
    compartment_id = var.compartment_id
    vcn_id         = oci_core_vcn.tucsocial_vcn.id
}

// Now we need to add a route rule to the public subnet's route table to connect it to the internet

resource "oci_core_route_table" "tucsocial_public_route_table" {
    display_name   = "${var.display_name}_public_route_table"
    compartment_id = var.compartment_id
    vcn_id         = oci_core_vcn.tucsocial_vcn.id
}

resource "oci_core_route_table_route" "tucsocial_public_route_table_route" {
    destination     = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.tucsocial_ig.id
    route_table_id = oci_core_route_table.tucsocial_public_route_table.id
}

// Now we need to create a security list for the public subnet

resource "oci_core_security_list" "tucsocial_public_security_list" {
    display_name   = "${var.display_name}_public_security_list"
    compartment_id = var.compartment_id
    vcn_id         = oci_core_vcn.tucsocial_vcn.id
}

// first security rule is to allow traffic from itself

resource "oci_core_security_list_security_rule" "tucsocial_public_security_list_security_rule_self" {
    direction = "INGRESS"
    protocol = "all"
    source = oci_core_subnet.tucsocial_public_subnet.cidr_block
    security_list_id = oci_core_security_list.tucsocial_public_security_list.id
}

// second security rule is to allow traffic from the private subnet

resource "oci_core_security_list_security_rule" "tucsocial_public_security_list_security_rule_private" {
    direction = "INGRESS"
    protocol = "all"
    source = oci_core_subnet.tucsocial_private_subnet.cidr_block
    security_list_id = oci_core_security_list.tucsocial_public_security_list.id
}

// Now we need to add a security rule to the public security list to allow HTTP traffic

resource "oci_core_security_list_security_rule" "tucsocial_public_security_list_security_rule_web" {
    direction = "INGRESS"
    protocol = "6"
    source = "0.0.0.0/0"
    tcp_options {
        destination_port_range {
            max = 80
            min = 80
        }
    }
    security_list_id = oci_core_security_list.tucsocial_public_security_list.id
}

// and another to allow HTTPS traffic

resource "oci_core_security_list_security_rule" "tucsocial_public_security_list_security_rule_web_secure" {
    direction = "INGRESS"
    protocol = "6"
    source = "0.0.0.0/0"
    tcp_options {
        destination_port_range {
            max = 443
            min = 443
        }
    }
    security_list_id = oci_core_security_list.tucsocial_public_security_list.id
}

// Now for ssh

resource "oci_core_security_list_security_rule" "tucsocial_public_security_list_security_rule_ssh" {
    count = var.whitelisted_ip != null ? 1 : 0

    direction        = "INGRESS"
    protocol         = "6"
    source           = var.whitelisted_ip
    security_list_id = oci_core_security_list.tucsocial_public_security_list.id

    tcp_options {
        destination_port_range {
            max = 22
            min = 22
        }
    }
}

// Now we need to create a security list for the private subnet

resource "oci_core_security_list" "tucsocial_private_security_list" {
    display_name   = "${var.display_name}_private_security_list"
    compartment_id = var.compartment_id
    vcn_id         = oci_core_vcn.tucsocial_vcn.id
}

// allow all protocols from the private subnet to the private subnet

resource "oci_core_security_list_security_rule" "tucsocial_private_security_list_security_rule_self" {
    direction = "INGRESS"
    protocol = "all"
    source = oci_core_subnet.tucsocial_private_subnet.cidr_block
    security_list_id = oci_core_security_list.tucsocial_private_security_list.id
}

// allow lemmy traffic from the public subnet to the private subnet

// Now we need to add a security rule to the private security list to allow lemmy traffic over port 8536 from the public subnet where the load balancer is

resource "oci_core_security_list_security_rule" "tucsocial_private_security_list_security_rule_lemmy" {
    direction = "INGRESS"
    protocol = "6"
    source = var.public_subnet_cidr_block
    tcp_options {
        destination_port_range {
            max = 8536
            min = 8536
        }
    }
    security_list_id = oci_core_security_list.tucsocial_private_security_list.id
}

// and another to allow SSH traffic over port 22
resource "oci_core_security_list_security_rule" "tucsocial_private_security_list_security_rule_ssh" {
    count = var.whitelisted_ip != null ? 1 : 0

    direction        = "INGRESS"
    protocol         = "6"
    source           = var.whitelisted_ip
    security_list_id = oci_core_security_list.tucsocial_private_security_list.id

    tcp_options {
        destination_port_range {
            max = 22
            min = 22
        }
    }
}

// Now we need to create a public IP address for the public subnet

resource "oci_core_public_ip" "tucsocial_public_ip" {
    compartment_id = var.compartment_id
    display_name   = "${var.display_name}_public_ip"
    lifetime       = "EPHEMERAL"
    vnic_id        = oci_core_instance.tucsocial_public_instance.primary_vnic_id
}