//lemmy's background daemon is not known to be horizontally scalable, so we'll just use a single container instance
// Here is the definition of a container instance:
# resource "oci_container_instances_container_instance" "test_container_instance" {
#     #Required
#     availability_domain = var.container_instance_availability_domain
#     compartment_id = var.compartment_id
#     containers {
#         #Required
#         image_url = var.container_instance_containers_image_url

#         #Optional
#         additional_capabilities = var.container_instance_containers_additional_capabilities
#         arguments = var.container_instance_containers_arguments
#         command = var.container_instance_containers_command
#         defined_tags = var.container_instance_containers_defined_tags
#         display_name = var.container_instance_containers_display_name
#         environment_variables = var.container_instance_containers_environment_variables
#         freeform_tags = var.container_instance_containers_freeform_tags
#         health_checks {
#             #Required
#             health_check_type = var.container_instance_containers_health_checks_health_check_type

#             #Optional
#             command = var.container_instance_containers_health_checks_command
#             failure_action = var.container_instance_containers_health_checks_failure_action
#             failure_threshold = var.container_instance_containers_health_checks_failure_threshold
#             headers {

#                 #Optional
#                 name = var.container_instance_containers_health_checks_headers_name
#                 value = var.container_instance_containers_health_checks_headers_value
#             }
#             initial_delay_in_seconds = var.container_instance_containers_health_checks_initial_delay_in_seconds
#             interval_in_seconds = var.container_instance_containers_health_checks_interval_in_seconds
#             name = var.container_instance_containers_health_checks_name
#             path = var.container_instance_containers_health_checks_path
#             port = var.container_instance_containers_health_checks_port
#             success_threshold = var.container_instance_containers_health_checks_success_threshold
#             timeout_in_seconds = var.container_instance_containers_health_checks_timeout_in_seconds
#         }
#         is_resource_principal_disabled = var.container_instance_containers_is_resource_principal_disabled
#         resource_config {

#             #Optional
#             memory_limit_in_gbs = var.container_instance_containers_resource_config_memory_limit_in_gbs
#             vcpus_limit = var.container_instance_containers_resource_config_vcpus_limit
#         }
#         volume_mounts {
#             #Required
#             mount_path = var.container_instance_containers_volume_mounts_mount_path
#             volume_name = var.container_instance_containers_volume_mounts_volume_name

#             #Optional
#             is_read_only = var.container_instance_containers_volume_mounts_is_read_only
#             partition = var.container_instance_containers_volume_mounts_partition
#             sub_path = var.container_instance_containers_volume_mounts_sub_path
#         }
#         working_directory = var.container_instance_containers_working_directory
#     }
#     shape = var.container_instance_shape
#     shape_config {
#         #Required
#         ocpus = var.container_instance_shape_config_ocpus

#         #Optional
#         memory_in_gbs = var.container_instance_shape_config_memory_in_gbs
#     }
#     vnics {
#         #Required
#         subnet_id = oci_core_subnet.test_subnet.id

#         #Optional
#         defined_tags = var.container_instance_vnics_defined_tags
#         display_name = var.container_instance_vnics_display_name
#         freeform_tags = var.container_instance_vnics_freeform_tags
#         hostname_label = var.container_instance_vnics_hostname_label
#         is_public_ip_assigned = var.container_instance_vnics_is_public_ip_assigned
#         nsg_ids = var.container_instance_vnics_nsg_ids
#         private_ip = var.container_instance_vnics_private_ip
#         skip_source_dest_check = var.container_instance_vnics_skip_source_dest_check
#     }

#     #Optional
#     container_restart_policy = var.container_instance_container_restart_policy
#     defined_tags = {"foo-namespace.bar-key"= "value"}
#     display_name = var.container_instance_display_name
#     dns_config {

#         #Optional
#         nameservers = var.container_instance_dns_config_nameservers
#         options = var.container_instance_dns_config_options
#         searches = var.container_instance_dns_config_searches
#     }
#     fault_domain = var.container_instance_fault_domain
#     freeform_tags = {"bar-key"= "value"}
#     graceful_shutdown_timeout_in_seconds = var.container_instance_graceful_shutdown_timeout_in_seconds
#     image_pull_secrets {
#         #Required
#         registry_endpoint = var.container_instance_image_pull_secrets_registry_endpoint
#         secret_type = var.container_instance_image_pull_secrets_secret_type

#         #Optional
#         password = var.container_instance_image_pull_secrets_password
#         secret_id = oci_vault_secret.test_secret.id
#         username = var.container_instance_image_pull_secrets_username
#     }
#     volumes {
#         #Required
#         name = var.container_instance_volumes_name
#         volume_type = var.container_instance_volumes_volume_type

#         #Optional
#         backing_store = var.container_instance_volumes_backing_store
#         configs {

#             #Optional
#             data = var.container_instance_volumes_configs_data
#             file_name = var.container_instance_volumes_configs_file_name
#             path = var.container_instance_volumes_configs_path
#         }
#     }
# }


// Now, let's only create variables for the required fields, I'll add the optional ones later.
resource "oci_container_instances_container_instance" "lemmy" {
    compartment_id = var.compartment_id
    display_name = var.display_name
    shape = var.shape
    shape_config {
        ocpus = var.ocpus
    }
    vnics {
        subnet_id = var.subnet_id
    }
    container {
        image = var.image
        command = var.command
        environment_variables = var.environment_variables
        volume_mounts {
            volume_name = var.volume_name
            mount_path = var.mount_path
        }
    }
    image_pull_secrets {
        registry_endpoint = var.registry_endpoint
        secret_type = var.secret_type
        secret_id = var.secret_id
    }
    volumes {
        name = var.volume_name
        volume_type = var.volume_type
    }
}