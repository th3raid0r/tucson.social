terraform {
  required_version = ">= 1.4" 
  required_providers {
    oci = {
      source = "oracle-terraform-modules/oci"
      version = ">= 5.0.0"
    }
  }
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

// Create a single, large VM instance for Lemmy. This will eventually be converted to a container instance for each microservice in the stack

//first let's get the latest oracle linux image

data "oci_core_images" "ol_latest" {
  compartment_id = var.compartment_ocid
  operating_system = "Oracle Linux"
  operating_system_version = "9"
  shape = "VM.Standard.E4.Flex"
  sort_by = "TIMECREATED"
  sort_order = "DESC"
  limit = 1
}

data "oci_core_volume_backup_policies" "boot_volume_backup_policy" {
  #  count = var.add_iscsi_volume ? 1 : 0

  filter {
    name   = "display_name"
    values = [var.boot_volume_backup_policy_level]
    regex  = true
  }
}


data "oci_core_volume_backup_policies" "block_volume_backup_policy" {
  #  count = var.add_iscsi_volume ? 1 : 0

  filter {
    name   = "display_name"
    values = [var.block_volume_backup_policy_level]
    regex  = true
  }
}

// Now the instance definition

resource "oci_core_instance" "lemmy" {
  display_name = "${var.display_name}-single-lemmy"
  compartment_id = var.compartment_ocid
  availability_domain = var.availability_domain
  fault_domain = var.fault_domain
  shape = var.instance_shape
  shape_config {
    ocpus = var.instance_flex_shape_ocpus
    memory_in_gbs = var.instance_flex_shape_memory_in_gbs
  }
  agent_config {
    are_all_plugins_disabled = false
    is_management_disabled = false
    is_monitoring_disabled = false
    plugins_config {
        desired_state = "ENABLED"
        name = "Bastion"
    }
  }
  create_vnic_details {
    subnet_id = var.private_subnet_id
    assign_public_ip = false
    display_name = "${var.display_name}-lemmy-vnic"
    hostname_label = "${var.display_name}-lemmy"
  }
  source_details {
    source_type = "image"
    source_id = data.oci_core_images.ol_latest.images.0.id
  }
  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }
  backup_policy_id = data.oci_core_volume_backup_policies.boot_volume_backup_policy.volume_backup_policies[0].id
  freeform_tags = var.tags
}

// I'll need 200GB of block storage for the images and video files (for now)

resource "oci_core_volume" "pictrs" {
  availability_domain = var.ad
  compartment_id = var.compartment_ocid
  display_name = "${var.display_name}-pictrs-volume"
  size_in_gbs = 200
  freeform_tags = var.tags
  #kms_key_id = ""
  vpus_per_gb = 10
  block_volume_replicas_deletion = false
}

// before attaching to an instance, let's attach a backup policy


resource "oci_core_volume_backup_policy_assignment" "pictrs" {
  asset_id = oci_core_volume.pictrs.id
  policy_id = data.oci_core_volume_backup_policies.block_volume_backup_policy.volume_backup_policies[0].id
}

// one more volume - 50gb for the db storage for now.

resource "oci_core_volume" "database" {
  availability_domain = var.ad
  compartment_id = var.compartment_ocid
  display_name = "${var.display_name}-database-volume"
  size_in_gbs = 50
  freeform_tags = var.tags
  #kms_key_id = ""
  vpus_per_gb = 10
  block_volume_replicas_deletion = false
}

// and another policy attachment

resource "oci_core_volume_backup_policy_assignment" "database" {
  asset_id = oci_core_volume.database.id
  policy_id = data.oci_core_volume_backup_policies.block_volume_backup_policy.volume_backup_policies[0].id
}

// now attach the volumes to the instance

resource "oci_core_volume_attachment" "pictrs" {
  attachment_type = "iscsi"
  instance_id = oci_core_instance.lemmy.id
  volume_id = oci_core_volume.pictrs.id
  display_name = "${var.display_name}-pictrs-volume-attachment"
}

resource "oci_core_volume_attachment" "database" {
  attachment_type = "iscsi"
  instance_id = oci_core_instance.lemmy.id
  volume_id = oci_core_volume.database.id
  display_name = "${var.display_name}-database-volume-attachment"
}

// now a Bastion service to allow SSH access to the instance
// but first, a sleep to allow the instance to be created
resource "time_sleep" "wait_lemmy" {
  depends_on = [oci_core_instance.lemmy]
  create_duration = "60s"
  triggers = {
    changed_time_stamp = length(data.oci_computeinstanceagent_instance_agent_plugins.lemmy.instance_agent_plugins) > 0 ? timestamp() : null
    instance_ocid  = oci_core_instance.lemmy.id
}

resource "oci_bastion_bastion" "lemmy" {
  bastion_type                 = "STANDARD"
  compartment_id               = var.compartment_ocid
  target_subnet_id             = var.private_subnet_id
  client_cidr_block_allow_list = ["${var.whitelisted_ips}/32"]
  max_session_ttl_in_seconds   = 10800
  name                        = "${var.display_name}-lemmy-bastion"
  freeform_tags = var.tags
}

// and a bastion session to allow access to the instance

resource "oci_bastion_session" "lemmy" {
    display_name = "${var.display_name}-lemmy-bastion-session"
    bastion_id = oci_bastion_bastion.lemmy.id
    bastion_session_ttl_in_seconds = 10800
    target_resource_details {
      target_resource_id = time_sleep.wait_lemmy.triggers["instance_ocid"]
      session_type = "MANAGED_SSH"
      target_resource_operating_system_user_name = "opc"
      target_resource_port                       = 22
      target_resource_private_ip_address         = oci_core_instance.lemmy.private_ip
    }
    key_details {
      public_key_content = var.ssh_public_key
    }
    key_type = "PUB"
}

// use a loadbalancer to forward 80 and 443 to the instance

resource "oci_load_balancer_load_balancer" "lemmy" {
  compartment_id = var.compartment_ocid
  display_name = "${var.display_name}-lemmy-lb"
  shape_name = "flexible"
  subnet_ids = [var.public_subnet_id]
  freeform_tags = var.tags
}

resource "oci_load_balancer_backend_set" "lemmy" {
  load_balancer_id = oci_load_balancer_load_balancer.lemmy.id
  name = "${var.display_name}-lemmy-backend-set"
  policy = "ROUND_ROBIN"
  health_checker {
    protocol = "HTTP"
    url_path = "/"
    port = 80
    retries = 3
    return_code = 200
    timeout_in_millis = 3000
  }
}

resource "oci_load_balancer_backend" "lemmy" {
  backend_set_name = oci_load_balancer_backend_set.lemmy.name
  load_balancer_id = oci_load_balancer_load_balancer.lemmy.id
  name = "${var.display_name}-lemmy-backend"
  ip_address = oci_core_instance.lemmy.private_ip
  port = 80
  backup = false
  drain = false
  offline = false
  weight = 1
}

// the listener should just forward to the backend set

resource "oci_load_balancer_listener" "lemmy" {
  default_backend_set_name = oci_load_balancer_backend_set.lemmy.name
  load_balancer_id = oci_load_balancer_load_balancer.lemmy.id
  name = "${var.display_name}-lemmy-listener"   
  port = 80
  protocol = "TCP"
}

resource "oci_load_balancer_backend_set" "lemmy-ssl" {
  load_balancer_id = oci_load_balancer_load_balancer.lemmy.id
  name = "${var.display_name}-lemmy-ssl-backend-set"
  policy = "ROUND_ROBIN"
  health_checker {
    protocol = "TCP"
    url_path = "/"
    port = 443
    retries = 3
    timeout_in_millis = 3000
  }
}

resource "oci_load_balancer_backend" "lemmy-ssl" {
  backend_set_name = oci_load_balancer_backend_set.lemmy-ssl.name
  load_balancer_id = oci_load_balancer_load_balancer.lemmy.id
  name = "${var.display_name}-lemmy-ssl-backend"
  ip_address = oci_core_instance.lemmy.private_ip
  port = 443
  backup = false
  drain = false
  offline = false
  weight = 1
}

resource "oci_load_balancer_listener" "lemmy-ssl" {
  default_backend_set_name = oci_load_balancer_backend_set.lemmy-ssl.name
  load_balancer_id = oci_load_balancer_load_balancer.lemmy.id
  name = "${var.display_name}-lemmy-ssl-listener"
  port = 443
  protocol = "TCP"
}

// DNS Will be managed at cloudflare manually for now, so skip that.



