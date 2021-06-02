resource "openstack_compute_servergroup_v2" "servergroup" {
  name     = "${var.name_prefix}-servergroup"
  policies = [var.server_affinity]
}

resource "openstack_compute_instance_v2" "instance" {
  depends_on   = [var.node_depends_on]
  count        = var.nodes_count
  name         = var.is_master && var.bootstrap_server != "" ? "${var.name_prefix}-${format("%03d", count.index + 2)}" : "${var.name_prefix}-${format("%03d", count.index + 1)}"
  image_name   = var.boot_from_volume ? null : var.image_name
  flavor_name  = var.flavor_name
  key_pair     = var.keypair_name
  config_drive = var.config_drive
  user_data = base64encode(templatefile(("${path.module}/files/cloud-init.yml.tpl"),
    { bootstrap_server      = var.bootstrap_server
      master_public_address = var.is_master ? openstack_networking_floatingip_v2.floating_ip[0].address : ""
      rke2_cluster_secret   = "toto"
      is_master             = var.is_master
  }))

  stop_before_destroy     = true
  availability_zone_hints = length(var.availability_zones) > 0 ? var.availability_zones[count.index % length(var.availability_zones)] : null

  network {
    name = var.network_name
  }

  security_groups = [var.secgroup_name]

  scheduler_hints {
    group = openstack_compute_servergroup_v2.servergroup.id
  }

  dynamic "block_device" {
    for_each = var.boot_from_volume ? [{ size = var.boot_volume_size }] : []
    content {
      uuid                  = data.openstack_images_image_v2.image.id
      source_type           = "image"
      volume_size           = block_device.value["size"]
      boot_index            = 0
      destination_type      = "volume"
      delete_on_termination = true
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "openstack_networking_floatingip_v2" "floating_ip" {
  count = var.assign_floating_ip ? var.nodes_count : 0
  pool  = var.floating_ip_pool
}

resource "openstack_compute_floatingip_associate_v2" "associate_floating_ip" {
  count       = var.assign_floating_ip ? var.nodes_count : 0
  floating_ip = openstack_networking_floatingip_v2.floating_ip[count.index].address
  instance_id = openstack_compute_instance_v2.instance[count.index].id
}
