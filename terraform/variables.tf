variable "tenancy_ocid" {
  type = string
}

variable "user_ocid" {
  type = string
}

variable "fingerprint" {
  type = string
}

variable "private_key_path" {
  type = string
}

variable "root_compartment_ocid" {
  type = string
}

variable "postgresql_root_password" {
  type = string
}
  
variable "region" {
  type = string
  default = "us-phoenix-1"
}

variable "environment" {
  type = string
  default = "primary"
}

variable "owner" {
  type = string
  default = "projectOwner"
}

variable "project" {
    type = string
    default = "projectName"
}

variable "whitelisted_ip" {
    type = string
    default = ""
}
  
  
