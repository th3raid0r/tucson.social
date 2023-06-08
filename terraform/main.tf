provider "oci" {
  tenancy_ocid     = "your_tenancy_ocid"
  user_ocid        = "your_user_ocid"
  fingerprint      = "your_fingerprint"
  private_key_path = "path/to/your/private/key"
  region           = "phx"
}

// This is the terraform definition for tucson.social
// the alias for tucson.social is tucsocial
// First, create a VCN, subnet, and internet gateway with the network module at tfmodules/network

module "network" {
  source = "../tfmodules/network"
    display_name = "tucsocial"
    compartment_id = "your_compartment_ocid"
    vcn_cidr_block = "10.42.0.1/16"
    public_subnet_cidr_block = "10.42.0.1/24"
    private_subnet_cidr_block = "10.42.1.1/24"
}






