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

# variable "postgresql_root_password" {
#   type = string
# }

variable "region" {
  type    = string
  default = "us-phoenix-1"
}

variable "environment" {
  type    = string
  default = "primary"
}

variable "owner" {
  type    = string
  default = "brian@th3rogers.com"
}

variable "project" {
  type    = string
  default = "tucson.social"
}

variable "whitelisted_ip" {
  type    = string
  default = ""
}

variable "ssh_public_key_file" {
  type    = string
  default = ""
}

variable "boot_volume_backup_policy_level" {
  type    = string
  default = "GOLD"
}

variable "block_volume_backup_policy_level" {
  type    = string
  default = "GOLD"
}
