//A generic loadbalancer construct that can be used to create a loadbalancer in any environment
//This uses sane defaults for the loadbalancer, but can be overridden by passing in the appropriate variables.
//This module creates a loadbalancer, a backend set, and a listener.
//The backend set is created with a variable number of backend servers - default 1, and the listener is created with a variable number of ports -default 1.
//The backend servers are created with a variable number of ports - default 1.
//The backend servers are created with a variable number of backup servers - default 0.
//The backend servers are created with either public or private policies - default private

# Path: terraform\tfmodules\loadbalancer\main.tf
# Compare this snippet from terraform\main.tf:
# module "loadbalancer" {
#   source = "../tfmodules/loadbalancer"
#     display_name = "tucsocial"
#     compartment_id = "your_compartment_ocid"
#     subnet_id = "${module.network.public_subnet_id}"
#     backend_server_count = "2"
#     backend_server_port_count = "2"
#     backend_server_backup_count = "1"
#     backend_server_policy = "public"
#     listener_port_count = "2"
#     listener_protocol = "HTTP"
#     listener_path_route = "/*"
#     listener_hostnames = ["tucson.social"]
#     listener_ssl_cert = "tucson.social"






