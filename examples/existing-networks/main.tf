# If the assign_floating_ip is true, then a new network will be created - see the other examples. If it's false, use existing networks instead.

locals {
  networks = {
    controlplane = var.existing_network_name_controlplane
    loadbalancer = var.existing_network_name_loadbalancer
    worker       = var.existing_network_name_worker
  }

  subnets = {
    controlplane = var.existing_subnet_name_controlplane
    loadbalancer = var.existing_subnet_name_loadbalancer
    worker       = var.existing_subnet_name_worker
  }
}

data "openstack_networking_network_v2" "network" {
  for_each = local.networks
  name     = each.value
}

data "openstack_networking_subnet_v2" "subnet" {
  for_each   = local.subnets
  network_id = data.openstack_networking_network_v2.network[each.key].id
  name       = each.value
}

module "controlplane" {
  source                = "./../.."
  nodes_count           = 3
  assign_floating_ip    = var.assign_floating_ip
  existing_network_name = var.existing_network_name_controlplane
  network_id            = data.openstack_networking_network_v2.network["controlplane"].id
  subnet_id             = data.openstack_networking_subnet_v2.subnet["controlplane"].id
  cluster_name          = var.cluster_name
  write_kubeconfig      = var.write_kubeconfig
  image_name            = var.image_name
  flavor_name           = var.flavor_name_controlplane
  ssh_key_file          = var.ssh_key_file
  rke2_config           = file("server.yaml")
  #  manifests_path        = "./manifests"
}

module "loadbalancer" {
  source                = "./../../modules/agent"
  nodes_count           = 2
  existing_network_name = var.existing_network_name_loadbalancer
  node_config = merge(module.controlplane.node_config, {
    network_id = data.openstack_networking_network_v2.network["loadbalancer"].id
    subnet_id  = data.openstack_networking_subnet_v2.subnet["loadbalancer"].id
  })
  image_name  = var.image_name
  name_prefix = "lb"
  flavor_name = var.flavor_name_loadbalancer
  rke2_config = templatefile("${path.module}/agent.yaml.tpl", {
    foo_name = "bar"
  })
}

module "worker" {
  source                = "./../../modules/agent"
  nodes_count           = 3
  existing_network_name = var.existing_network_name_worker
  node_config = merge(module.controlplane.node_config, {
    network_id = data.openstack_networking_network_v2.network["worker"].id
    subnet_id  = data.openstack_networking_subnet_v2.subnet["worker"].id
  })
  image_name  = var.image_name
  name_prefix = "worker"
  flavor_name = var.flavor_name_worker
  rke2_config = templatefile("${path.module}/agent.yaml.tpl", {
    foo_name = "baz"
  })
}
