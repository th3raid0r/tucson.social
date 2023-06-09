provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = "phx"
}

// This is the terraform definition for tucson.social
// the alias for tucson.social is tucsocial
// First create an Identity Compartment so that we can create resources in it
resource "oci_identity_compartment" "tucsocial" {
  compartment_id = "your_compartment_ocid"
  name           = "tucsocial"
  description    = "tucson.social"
}




// Then, create a VCN, subnet, and internet gateway with the network module at tfmodules/network

module "network" {
  source = "../tfmodules/network"
    display_name = "tucsocial"
    compartment_id = var.root_compartment_id
    vcn_cidr_block = "10.42.0.1/16"
    public_subnet_cidr_block = "10.42.0.1/24"
    private_subnet_cidr_block = "10.42.1.1/24"
}

// Now let's use this VCN and subnet and deploy a postgresql cluster using github.com/oracle-devrel/terraform-oci-arch-postgresql

module "arch-postgresql" {
  source                        = "github.com/oracle-devrel/terraform-oci-arch-postgresql"
  tenancy_ocid                  = var.tenancy_ocid
  user_ocid                     = "<user_ocid>"
  fingerprint                   = "<finger_print>"
  private_key_path              = "<private_key_path>"
  region                        = "<oci_region>"
  availability_domain_name       = "<availability_domain_name>"
  compartment_ocid              = "<compartment_ocid>"
  use_existing_vcn              = true # You can inject your own VCN and subnet 
  create_in_private_subnet      = true # Subnet should be associated with NATGW and proper Route Table.
  postgresql_vcn                = oci_core_virtual_network.my_vcn.id # Injected VCN
  postgresql_subnet             = oci_core_subnet.my_private_subnet.id # Injected Private Subnet
  postgresql_password           = "<password>"
  postgresql_deploy_hotstandby1 = true # if we want to setup hotstandby1
  postgresql_deploy_hotstandby2 = true # if we want to setup hotstandby2
}



