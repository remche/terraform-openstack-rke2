module "controlplane" {
  source           = "remche/rke2/openstack"
  nodes_count      = 3
  write_kubeconfig = true
  image_name       = "ubuntu-20.04-focal-x86_64"
  flavor_name      = "m1.small"
  public_net_name  = "public"
  rke2_config_file = "server.yaml"
  manifests_path   = "./manifests"
}

module "blue_node" {
  source           = "remche/rke2/openstack//modules/agent"
  image_name       = "ubuntu-20.04-focal-x86_64"
  nodes_count      = 1
  name_prefix      = "blue"
  flavor_name      = "m1.small"
  node_config      = module.controlplane.node_config
  rke2_config_file = "agent.yaml"
}

module "green_node" {
  source      = "remche/rke2/openstack//modules/agent"
  image_name  = "ubuntu-20.04-focal-x86_64"
  nodes_count = 1
  name_prefix = "green"
  flavor_name = "m1.small"
  node_config = module.controlplane.node_config
}

output "controlplane_floating_ip" {
  value     = module.controlplane.controlplane_floating_ip
  sensitive = true
}
