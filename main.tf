locals {
  node_config = {
    cluster_name       = var.cluster_name
    keypair_name       = module.keypair.keypair_name
    network_name       = module.network.nodes_net_name
    secgroup_name      = module.secgroup.secgroup_name
    server_affinity    = var.worker_server_affinity
    config_drive       = var.nodes_config_drive
    floating_ip_pool   = var.public_net_name
    user_data          = var.user_data_file != null ? file(var.user_data_file) : null
    boot_from_volume   = var.boot_from_volume
    boot_volume_size   = var.boot_volume_size
    availability_zones = var.availability_zones
    bootstrap_server   = module.master_bootstrap.bootstrap_ip
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
  #bastion_host = var.bastion_host != null ? var.bastion_host : values(module.master.nodes)[0].floating_ip
}

module "master_bootstrap" {
  source             = "./modules/node"
  node_depends_on    = [module.network.nodes_subnet]
  name_prefix        = "${var.cluster_name}-master"
  nodes_count        = 1
  image_name         = var.image_name
  flavor_name        = var.flavor_name
  keypair_name       = module.keypair.keypair_name
  network_name       = module.network.nodes_net_name
  secgroup_name      = module.secgroup.secgroup_name
  server_affinity    = var.master_server_affinity
  assign_floating_ip = "true"
  config_drive       = var.nodes_config_drive
  floating_ip_pool   = var.public_net_name
  user_data          = var.user_data_file != null ? file(var.user_data_file) : null
  boot_from_volume   = var.boot_from_volume
  boot_volume_size   = var.boot_volume_size
  availability_zones = var.availability_zones
}

module "master" {
  source             = "./modules/node"
  node_depends_on    = [module.network.nodes_subnet]
  name_prefix        = "${var.cluster_name}-master"
  nodes_count        = var.nodes_count - 1
  image_name         = var.image_name
  flavor_name        = var.flavor_name
  keypair_name       = module.keypair.keypair_name
  network_name       = module.network.nodes_net_name
  secgroup_name      = module.secgroup.secgroup_name
  server_affinity    = var.master_server_affinity
  assign_floating_ip = "true"
  config_drive       = var.nodes_config_drive
  floating_ip_pool   = var.public_net_name
  user_data          = var.user_data_file != null ? file(var.user_data_file) : null
  boot_from_volume   = var.boot_from_volume
  boot_volume_size   = var.boot_volume_size
  availability_zones = var.availability_zones
  bootstrap_server   = module.master_bootstrap.bootstrap_ip
}

resource "null_resource" "write_kubeconfig" {
  count = var.write_kubeconfig ? 1 : 0
  triggers = {
    always_run = "${timestamp()}"
  }

  connection {
    host        = module.master_bootstrap.floating_ip[0]
    user        = var.system_user
    private_key = var.use_ssh_agent ? null : file(var.ssh_key_file)
    agent       = var.use_ssh_agent
  }

  provisioner "remote-exec" {
    inline = ["while [ ! -r /etc/rancher/rke2/rke2.yaml ]; do echo Waiting for rke2 to start && sleep 10; done;"]
  }

  provisioner "local-exec" {
    command = var.use_ssh_agent ? "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ${var.ssh_key_file} ubuntu@${module.master_bootstrap.floating_ip[0]}:/etc/rancher/rke2/rke2.yaml ." : "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@${module.master_bootstrap.floating_ip[0]}:/etc/rancher/rke2/rke2.yaml ."

  }
}
