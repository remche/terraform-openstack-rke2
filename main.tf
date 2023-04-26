locals {
  node_config = {
    cluster_name  = var.cluster_name
    keypair_name  = module.keypair.keypair_name
    ssh_key_file  = var.ssh_key_file
    system_user   = var.system_user
    use_ssh_agent = var.use_ssh_agent
    # If assign_floating_ip is true, set network_id and subnet_id to the value of module.network.nodes_net_id and module.network.nodes_subnet_id, respectively
    # If assign_floating_ip is false, set network_id and subnet_id to the value of var.network_id and var.subnet_id, respectively
    network_id         = var.assign_floating_ip ? module.network.nodes_net_id : var.network_id
    subnet_id          = var.assign_floating_ip ? module.network.nodes_subnet_id : var.subnet_id
    secgroup_id        = module.secgroup.secgroup_id
    server_affinity    = var.server_group_affinity
    config_drive       = var.nodes_config_drive
    floating_ip_pool   = var.public_net_name
    user_data          = var.user_data_file != null ? file(var.user_data_file) : null
    boot_from_volume   = var.boot_from_volume
    boot_volume_size   = var.boot_volume_size
    boot_volume_type   = var.boot_volume_type
    availability_zones = var.availability_zones
    bootstrap_server   = var.assign_floating_ip ? module.server.floating_ip[0] : module.server.internal_ip[0]
    bastion_host       = var.assign_floating_ip ? module.server.floating_ip[0] : module.server.internal_ip[0]
    rke2_token         = random_string.rke2_token.result
    registries_conf    = var.registries_conf
  }
  tmpdir      = "${path.root}/.terraform/tmp/rke2"
  ssh_key_arg = var.use_ssh_agent ? "" : "-i ${var.ssh_key_file}"
  ssh         = "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${local.ssh_key_arg}"
  scp         = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${local.ssh_key_arg}"
  # If assign_floating_ip is true, the provisioner will try to connect to the floating_ip of the module.server resource to get the rendered rke2-remote.yaml
  # If assign_floating_ip is false, the provisioner will try to connect to the internal_ip of the first module.server resource to get the rendered rke2-remote.yaml
  remote_rke2_yaml = "${var.system_user}@${var.assign_floating_ip ? module.server.floating_ip[0] : module.server.internal_ip[0]}:/etc/rancher/rke2/rke2-remote.yaml"
}

module "keypair" {
  source           = "./modules/keypair"
  cluster_name     = var.cluster_name
  ssh_key_file     = var.ssh_key_file
  ssh_keypair_name = var.ssh_keypair_name
}

module "network" {
  source                = "./modules/network"
  network_name          = "${var.cluster_name}-nodes-net"
  subnet_name           = "${var.cluster_name}-nodes-subnet"
  router_name           = "${var.cluster_name}-router"
  nodes_net_cidr        = var.nodes_net_cidr
  dns_servers           = var.dns_servers
  dns_domain            = var.dns_domain
  network_id            = var.network_id
  subnet_id             = var.subnet_id
  assign_floating_ip    = var.assign_floating_ip
  existing_network_name = var.existing_network_name
  public_net_name       = var.public_net_name
}

module "secgroup" {
  source      = "./modules/secgroup"
  name_prefix = var.cluster_name
  rules       = var.secgroup_rules
}

module "server" {
  source                 = "./modules/node"
  cluster_name           = var.cluster_name
  name_prefix            = "${var.cluster_name}-server"
  nodes_count            = var.nodes_count
  image_name             = var.image_name
  image_id               = var.image_id
  instance_tags          = var.instance_tags
  flavor_name            = var.flavor_name
  keypair_name           = module.keypair.keypair_name
  ssh_key_file           = var.ssh_key_file
  system_user            = var.system_user
  use_ssh_agent          = var.use_ssh_agent
  network_id             = var.assign_floating_ip ? module.network.nodes_net_id : var.network_id
  subnet_id              = var.assign_floating_ip ? module.network.nodes_subnet_id : var.subnet_id
  secgroup_id            = module.secgroup.secgroup_id
  server_affinity        = var.server_group_affinity
  assign_floating_ip     = var.assign_floating_ip
  config_drive           = var.nodes_config_drive
  floating_ip_pool       = var.public_net_name
  user_data              = var.user_data_file != null ? file(var.user_data_file) : null
  boot_from_volume       = var.boot_from_volume
  boot_volume_size       = var.boot_volume_size
  boot_volume_type       = var.boot_volume_type
  availability_zones     = var.availability_zones
  rke2_version           = var.rke2_version
  rke2_config            = var.rke2_config
  containerd_config_file = var.containerd_config_file
  registries_conf        = var.registries_conf
  rke2_token             = random_string.rke2_token.result
  additional_san         = var.additional_san
  manifests_path         = var.manifests_path
  manifests_gzb64        = var.manifests_gzb64
  do_upgrade             = var.do_upgrade
  existing_network_name  = var.existing_network_name
  bastion_host           = local.node_config.bastion_host
}

resource "local_file" "tmpdirfile" {
  content  = ""
  filename = "${local.tmpdir}/placeholder"
}

resource "random_string" "rke2_token" {
  length = 64
}
