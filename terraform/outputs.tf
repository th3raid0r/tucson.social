//output all variables from all modules 

output "vcn_id" {
  value = module.network.vcn_id
}

# output "vcn_cidr_block" {
#   value = module.network.vcn_cidr_block
# }

output "public_subnet_id" {
  value = module.network.public_subnet_id
}

# output "public_subnet_cidr_block" {
#   value = module.network.public_subnet_cidr_block
# }

output "private_subnet_id" {
  value = module.network.private_subnet_id
}

# output "private_subnet_cidr_block" {
#   value = module.network.private_subnet_cidr_block
# }

output "public_route_table_id" {
  value = module.network.public_route_table_id
}

output "public_security_list_id" {
  value = module.network.public_security_list_id
}

output "private_security_list_id" {
  value = module.network.private_security_list_id
}

output "public_security_list_security_rule_web_id" {
  value = module.network.public_security_list_security_rule_web_id
}

output "public_security_list_security_rule_web_secure_id" {
  value = module.network.public_security_list_security_rule_web_secure_id
}

output "private_security_list_security_rule_ssh_id" {
  value = module.network.private_security_list_security_rule_ssh_id
}

output "private_security_list_security_rule_lemmy_id" {
  value = module.network.private_security_list_security_rule_lemmy_id
}

# output "bastion_ssh_postgresql_master_session_metadata" {
#   value = module.arch-postgresql.bastion_ssh_postgresql_master_session_metadata
# }

# output "bastion_ssh_postgresql_hotstandby1_session_metadata" {
#   value = module.arch-postgresql.bastion_ssh_postgresql_hotstandby1_session_metadata
# }

# output "bastion_ssh_postgresql_hotstandby2_session_metadata" {
#   value = module.arch-postgresql.bastion_ssh_postgresql_hotstandby2_session_metadata
# }

# output "postgresql_master_session_private_ip" {
#   value = module.arch-postgresql.postgresql_master_session_private_ip
# }

# output "postgresql_hotstandby1_private_ip" {
#   value = module.arch-postgresql.postgresql_hotstandby1_private_ip
# }

# output "postgresql_hotstandby2_private_ip" {
#   value = module.arch-postgresql.postgresql_hotstandby2_private_ip
# }

# output "generated_ssh_private_key" {
#   value     = module.arch-postgresql.generated_ssh_private_key
#   sensitive = true
# }

output "lemmy_public_ip" {
  value = module.single-lemmy-instance.public_ip
}

output "lemmy_private_ip" {
  value = module.single-lemmy-instance.private_ip
}

output "bastion_session_lemmy_public_key_host_info" {
  value = module.single-lemmy-instance.bastion_public_key_host_info
}

output "bastion_session_lemmy_user_name" {
  value = module.single-lemmy-instance.bastion_user_name
}

output "bastion_session_lemmy_ssh_metadata" {
  value = module.single-lemmy-instance.bastion_ssh_metadata
}

 