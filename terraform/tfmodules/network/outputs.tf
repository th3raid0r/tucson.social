output "vcn_id" {
  value = oci_core_vcn.tucsocial_vcn.id
}

output "public_subnet_id" {
  value = oci_core_subnet.tucsocial_public_subnet.id
}

output "private_subnet_id" {
  value = oci_core_subnet.tucsocial_private_subnet.id
}

output "public_route_table_id" {
  value = oci_core_route_table.tucsocial_public_route_table.id
}

output "public_security_list_id" {
  value = oci_core_security_list.tucsocial_public_security_list.id
}

output "private_security_list_id" {
  value = oci_core_security_list.tucsocial_private_security_list.id
}

output "public_security_list_security_rule_web_id" {
  value = oci_core_security_list_security_rule.tucsocial_public_security_list_security_rule_web.id
}

output "public_security_list_security_rule_web_secure_id" {
  value = oci_core_security_list_security_rule.tucsocial_public_security_list_security_rule_web_secure.id
}

output "private_security_list_security_rule_ssh_id" {
  value = oci_core_security_list_security_rule.tucsocial_private_security_list_security_rule_ssh.id
}

output "private_security_list_security_rule_lemmy_id" {
  value = oci_core_security_list_security_rule.tucsocial_private_security_list_security_rule_lemmy.id
}
