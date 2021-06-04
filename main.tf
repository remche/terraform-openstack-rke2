locals {
  node_config = {
    cluster_name       = var.cluster_name
    keypair_name       = module.keypair.keypair_name
    network_id         = module.network.nodes_net_id
    subnet_id          = module.network.nodes_subnet_id
    secgroup_id        = module.secgroup.secgroup_id
    server_affinity    = var.agent_group_affinity
    config_drive       = var.nodes_config_drive
    floating_ip_pool   = var.public_net_name
    user_data          = var.user_data_file != null ? file(var.user_data_file) : null
    boot_from_volume   = var.boot_from_volume
    boot_volume_size   = var.boot_volume_size
    availability_zones = var.availability_zones
    bootstrap_server   = module.server.bootstrap_ip
  }
}

module "keypair" {
  source           = "./modules/keypair"
  cluster_name     = var.cluster_name
  ssh_key_file     = var.ssh_key_file
  ssh_keypair_name = var.ssh_keypair_name
}

module "network" {
  source          = "./modules/network"
  network_name    = "${var.cluster_name}-nodes-net"
  subnet_name     = "${var.cluster_name}-nodes-subnet"
  router_name     = "${var.cluster_name}-router"
  nodes_net_cidr  = var.nodes_net_cidr
  public_net_name = var.public_net_name
  dns_servers     = var.dns_servers
  dns_domain      = var.dns_domain
}

module "secgroup" {
  source      = "./modules/secgroup"
  name_prefix = var.cluster_name
  rules       = var.secgroup_rules
}

module "server" {
  source             = "./modules/node"
  name_prefix        = "${var.cluster_name}-server"
  nodes_count        = var.nodes_count
  image_name         = var.image_name
  flavor_name        = var.flavor_name
  keypair_name       = module.keypair.keypair_name
  network_id         = module.network.nodes_net_id
  subnet_id          = module.network.nodes_subnet_id
  secgroup_id        = module.secgroup.secgroup_id
  server_affinity    = var.server_group_affinity
  assign_floating_ip = "true"
  config_drive       = var.nodes_config_drive
  floating_ip_pool   = var.public_net_name
  user_data          = var.user_data_file != null ? file(var.user_data_file) : null
  boot_from_volume   = var.boot_from_volume
  boot_volume_size   = var.boot_volume_size
  availability_zones = var.availability_zones
  rke2_config_file   = var.rke2_config_file
  additional_san     = var.additional_san
  manifests_path     = var.manifests_path
}

resource "null_resource" "write_kubeconfig" {
  count = var.write_kubeconfig ? 1 : 0
  triggers = {
    always_run = "${timestamp()}"
  }

  connection {
    host        = module.server.floating_ip[0]
    user        = var.system_user
    private_key = var.use_ssh_agent ? null : file(var.ssh_key_file)
    agent       = var.use_ssh_agent
  }

  provisioner "remote-exec" {
    inline = ["until (grep rke2 /etc/rancher/rke2/rke2.yaml); do echo Waiting for rke2 to start && sleep 10; done;"]
  }

  provisioner "local-exec" {
    command = var.use_ssh_agent ? "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ${var.ssh_key_file} ubuntu@${module.server.floating_ip[0]}:/etc/rancher/rke2/rke2.yaml ." : "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@${module.server.floating_ip[0]}:/etc/rancher/rke2/rke2.yaml ."

  }
}
