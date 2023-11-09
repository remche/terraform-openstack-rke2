locals {
  tmpdir = "${path.root}/.terraform/tmp/rke2"
}


resource "openstack_compute_servergroup_v2" "servergroup" {
  name     = "${var.name_prefix}-servergroup"
  policies = [var.server_affinity]
}

data "openstack_images_image_v2" "image" {
  name        = var.image_name
  most_recent = true
}

resource "openstack_compute_instance_v2" "instance" {
  depends_on   = [var.node_depends_on]
  count        = var.nodes_count
  name         = "${var.name_prefix}-${format("%03d", count.index + 1)}"
  image_id     = var.boot_from_volume ? null : var.image_id
  image_name   = var.boot_from_volume ? null : var.image_name
  flavor_name  = var.flavor_name
  key_pair     = var.keypair_name
  config_drive = var.config_drive
  user_data = base64encode(templatefile(("${path.module}/files/cloud-init.yml.tpl"),
    { cluster_name     = var.cluster_name
      bootstrap_server = var.is_server && count.index != 0 ? openstack_networking_port_v2.port[0].all_fixed_ips[0] : var.bootstrap_server
      public_address   = var.is_server ? openstack_networking_floatingip_v2.floating_ip[count.index].address : ""
      rke2_token       = var.rke2_token
      is_server        = var.is_server
      san              = openstack_networking_floatingip_v2.floating_ip[*].address
      system_user      = var.system_user
      rke2_conf        = var.rke2_config
      containerd_conf  = var.containerd_config_file
      registries_conf  = var.registries_conf
      additional_san   = var.additional_san
      manifests_files  = var.manifests_path != "" ? [for f in fileset(var.manifests_path, "*.{yml,yaml}") : [f, base64gzip(file("${var.manifests_path}/${f}"))]] : []
      manifests_gzb64  = var.manifests_gzb64
      proxy_url        = var.proxy_url
      no_proxy         = var.no_proxy
  }))
  metadata = {
    rke2_version = var.rke2_version
    rke2_role    = var.is_server ? "server" : "agent"
  }
  tags = var.instance_tags

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
      volume_type           = var.boot_volume_type
      boot_index            = 0
      destination_type      = "volume"
      delete_on_termination = true
    }
  }

  lifecycle {
    ignore_changes = [
      availability_zone_hints,
      flavor_name,
      image_id,
      image_name,
      user_data
    ]
  }
}

resource "openstack_networking_port_v2" "port" {
  count              = var.nodes_count
  network_id         = var.network_id
  security_group_ids = [var.secgroup_id]
  admin_state_up     = true
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

resource "null_resource" "upgrade" {
  count = var.do_upgrade ? var.nodes_count : 0

  triggers = {
    rke_version = var.rke2_version
  }

  connection {
    bastion_host = var.assign_floating_ip ? "" : var.bastion_host
    host         = var.assign_floating_ip ? openstack_networking_floatingip_v2.floating_ip[count.index].address : openstack_compute_instance_v2.instance[0].access_ip_v4
    user         = var.system_user
    private_key  = var.use_ssh_agent ? null : file(var.ssh_key_file)
    agent        = var.use_ssh_agent
  }

  provisioner "local-exec" {
    command = count.index == 0 ? "true" : "until [ -f ${local.tmpdir}/upgrade-${openstack_compute_instance_v2.instance[count.index - 1].id}-${var.rke2_version} ]; do sleep 10; done;"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo /usr/local/bin/install-or-upgrade-rke2.sh",
      "sudo systemctl restart %{if var.is_server} rke2-server.service %{else} rke2-agent.service %{endif}",
      "/usr/local/bin/wait-for-node-ready.sh"
    ]
  }

  provisioner "local-exec" {
    command = "touch ${local.tmpdir}/upgrade-${openstack_compute_instance_v2.instance[count.index].id}-${var.rke2_version}"
  }

}
