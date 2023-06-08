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