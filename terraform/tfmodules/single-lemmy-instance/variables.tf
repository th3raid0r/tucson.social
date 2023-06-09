variable "compartment_ocid" {
  type = string
}

variable "display_name" {
  type = string
}

variable "availability_domain" {
  type = string
}

variable "fault_domain" {
  type = string
}

variable "instance_shape" {
  type = string
}

variable "instance_flex_shape_ocpus" {
  type = number
}

variable "instance_flex_shape_memory_in_gbs" {
  type = number
}

variable "vcn_id" {
  type = string
}

variable "private_subnet_id" {
  type = string
}

variable "public_subnet_id" {
  type = string
}

variable "whitelisted_ip" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "ssh_public_key" {
  type = string
}