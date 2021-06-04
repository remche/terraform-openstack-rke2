resource "openstack_compute_servergroup_v2" "servergroup" {
  name     = "${var.name_prefix}-servergroup"
  policies = [var.server_affinity]
}

resource "openstack_compute_instance_v2" "instance" {
  depends_on   = [var.node_depends_on]
  count        = var.nodes_count
  name         = "${var.name_prefix}-${format("%03d", count.index + 1)}"
  image_name   = var.boot_from_volume ? null : var.image_name
  flavor_name  = var.flavor_name
  key_pair     = var.keypair_name
  config_drive = var.config_drive
  user_data = base64encode(templatefile(("${path.module}/files/cloud-init.yml.tpl"),
    { bootstrap_server    = var.is_server && count.index != 0 ? openstack_networking_port_v2.port[0].all_fixed_ips[0] : var.bootstrap_server
      public_address      = var.is_server ? openstack_networking_floatingip_v2.floating_ip[count.index].address : ""
      rke2_cluster_secret = "toto"
      is_server           = var.is_server
      san                 = openstack_networking_floatingip_v2.floating_ip[*].address
      rke2_conf           = var.rke2_config_file != "" ? file(var.rke2_config_file) : ""
      additional_san      = var.additional_san
  }))

  availability_zone_hints = length(var.availability_zones) > 0 ? var.availability_zones[count.index % length(var.availability_zones)] : null

  network {
    port = openstack_networking_port_v2.port[count.index].id
  }

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

resource "openstack_networking_port_v2" "port" {
  count               = var.nodes_count
  network_id          = var.network_id
  security_group_ids  = [var.secgroup_id]
  admin_state_up      = true
  fixed_ip {
    subnet_id = var.subnet_id
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
