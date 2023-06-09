output "name" {
  value = oci_core_instance.lemmy.display_name
}

output "private_ip" {
  value = oci_core_instance.lemmy.private_ip
}

output "public_ip" {
  value = oci_core_instance.lemmy.public_ip
}

output "bastion_public_key_host_info" {
  value = oci_bastion_session.lemmy.public_key_host_info
}

output "bastion_user_name" {
  value = oci_bastion_session.lemmy.user_name
}

output "bastion_ssh_metadata" {
  value = oci_bastion_session.lemmy.ssh_metadata
}

