variable "vcn_cidr_block" {
  type        = string
  description = "The CIDR block for the VCN"
}

variable "display_name" {
  type        = string
  description = "The display name for resources in this VCN"
}

variable "compartment_id" {
  type        = string
  description = "The compartment ID for the VCN"
}

variable "public_subnet_cidr_block" {
  type        = string
  description = "The CIDR block for the public subnet"
}

variable "private_subnet_cidr_block" {
  type        = string
  description = "The CIDR block for the public subnet"
}

variable "whitelisted_ip" {
  type        = string
  description = "The IP address to whitelist for SSH access"
}

variable "tags" {
  type        = map(string)
  description = "The tags to apply to resources in this VCN"
}

variable "tenancy_ocid" {
  type        = string
  description = "The OCID of the tenancy"
}

variable "user_ocid" {
  type        = string
  description = "The OCID of the user"
}

variable "fingerprint" {
  type        = string
  description = "The fingerprint of the public key"
}

variable "private_key_path" {
  type        = string
  description = "The path to the private key"
}

variable "root_compartment_ocid" {
  type        = string
  description = "The OCID of the root compartment"
}