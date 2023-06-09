
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

//Let's do a small local block to define a standard set of tags. These tags will be applied to all resources that support tags.
locals {
  common_tags = {
    "created_by" = "terraform"
    "created_on" = timestamp()
    "environment" = "primary"
    "owner" = "brian@th3rogers.com"
    "project" = "tucson.social"
  }
  // Now let's create raw public keys from the ssh_public_key_file variable
  ssh_public_key = file(var.ssh_public_key_file)
}

// This is the terraform definition for tucson.social
// the alias for tucson.social is tucsocial
// First create an Identity Compartment so that we can create resources in it
resource "oci_identity_compartment" "tucsocial" {
  compartment_id = var.root_compartment_ocid
  name           = "tucsocial"
  description    = "tucson.social"
  tags           = local.common_tags
}


// Then, create a VCN, subnet, and internet gateway with the network module at tfmodules/network

module "network" {
  source = "./tfmodules/network"
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
  display_name = "tucsocial"
  compartment_id = oci_identity_compartment.tucsocial.id
  vcn_cidr_block = "10.42.0.1/16"
  public_subnet_cidr_block = "10.42.0.1/24"
  private_subnet_cidr_block = "10.42.1.1/24"
  whitelisted_ip = var.whitelisted_ip
  tags = local.common_tags
}

data "oci_identity_availability_domains" "ad" {
  compartment_id = var.tenancy_ocid
}

data "oci_identity_fault_domains" "fd" {
  availability_domain = data.oci_identity_availability_domains.ad.availability_domains[0].name
  compartment_id = var.tenancy_ocid
}

// Now let's use this VCN and subnet and deploy a single instance for now.


module "single-lemmy-instance" {
  source                        = "./tfmodules/single-lemmy-instance"
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
  display_name                  = "tucsocial-lemmy"
  compartment_id                = oci_identity_compartment.tucsocial.id
  vcn_id                        = module.network.vcn_id
  subnet_id                     = module.network.private_subnet_id
  availability_domain           = oci_identity_availability_domains.ad.availability_domains[0].name
  fault_domain                  = data.oci_identity_fault_domains.fd.fault_domains[0].name
  whitelisted_ip                = var.whitelisted_ip
  ssh_public_key                = local.ssh_public_key
  instance_shape                = "VM.Standard.E4.Flex"
  instance_flex_shape_ocpus     = 2
  instance_flex_shape_memory_in_gbs = 8
  tags                          = local.common_tags
}


// Placeholder modules in order of scaling/redundancy priority.

# module "arch-postgresql" {
#   source                        = "oracle-terraform-modules/arch-postgresql"
#   tenancy_ocid                  = var.tenancy_ocid
#   user_ocid                     = var.user_ocid
#   fingerprint                   = var.fingerprint
#   private_key_path              = var.private_key_path
#   region                        = var.region
#   availability_domain_name      = data.oci_identity_availability_domains.ad.availability_domains[0].name
#   compartment_ocid              = oci_identity_compartment.tucsocial.id
#   use_existing_vcn              = true
#   create_in_private_subnet      = true
#   postgresql_vcn                = module.network.vcn_id
#   postgresql_subnet             = module.network.private_subnet_id
#   pg_whitelisted_ip             = var.whitelisted_ip
#   ssh_public_key     = local.ssh_public_key
#   add_iscsi_volume              = true
#   iscsi_volume_size_in_gbs      = 200
#   postgresql_instance_shape     = "VM.Standard.A1.Flex"
#   postgresql_instance_flex_shape_ocpus = 2
#   postgresql_instance_flex_shape_memory_in_gbs = 12
#   postgresql_password           = var.postgresql_root_password
#   postgresql_master_fd          = data.oci_identity_availability_domains.ad.availability_domains[0].fault_domains[0].name
#   postgresql_deploy_hotstandby1 = true
#   postgresql_hotstandby1_shape  = "VM.Standard.A1.Flex"
#   postgresql_hotstandby1_flex_shape_ocpus = 2
#   postgresql_hotstandby1_flex_shape_memory_in_gbs = 12
#   postgresql_hotstandby1_ad     = data.oci_identity_availability_domains.ad.availability_domains[1].name
#   postgresql_hotstandby1_fd     = data.oci_identity_availability_domains.ad.availability_domains[1].fault_domains[0].name
#   postgresql_deploy_hotstandby2 = false
# }

# module "pictrs-cluster" {
#   source = "./tfmodules/pictrs-cluster"
#   display_name = "tucsocial-pictrs-cluster"
#   compartment_id = oci_identity_compartment.tucsocial.id
#   vcn_id = module.network.vcn_id
#   subnet_id = module.network.private_subnet_id
#   whitelisted_ip = var.whitelisted_ip
#   tags = local.common_tags
# }

# module "lemmy-ui-cluster" {
#   source = "./tfmodules/lemmy-ui-cluster"
#   count = 1
#   display_name = "tucsocial-ui-cluster"
#   compartment_id = oci_identity_compartment.tucsocial.id
#   vcn_id = module.network.vcn_id
#   subnet_id = module.network.public_subnet_id
#   whitelisted_ip = var.whitelisted_ip
#   tags = local.common_tags
# }

# module "lemmy-container-instance" {
#   source = "./tfmodules/lemmy-container-instance"
#   display_name = "tucsocial-container-instance"
#   compartment_id = oci_identity_compartment.tucsocial.id
#   vcn_id = module.network.vcn_id
#   subnet_id = module.network.private_subnet_id
#   whitelisted_ip = var.whitelisted_ip
#   tags = local.common_tags
# }






