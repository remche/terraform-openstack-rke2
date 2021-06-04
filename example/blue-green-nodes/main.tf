module "controlplane" {
  source           = "./.."
  nodes_count      = 3
  write_kubeconfig = true
  image_name       = "ubuntu-20.04-focal-x86_64+rke2"
  flavor_name      = "m1.small"
  public_net_name  = "public"
  rke2_config_file = "server.yaml"
}

module "blue_node" {
  source           = "./..//modules/agent"
  image_name       = "ubuntu-20.04-focal-x86_64+rke2"
  nodes_count      = 1
  name_prefix      = "blue"
  flavor_name      = "m1.small"
  node_config      = module.controlplane.node_config
  rke2_config_file = "agent.yaml"
}

module "green_node" {
  source      = "./..//modules/agent"
  image_name  = "ubuntu-20.04-focal-x86_64+rke2"
  nodes_count = 1
  name_prefix = "green"
  flavor_name = "m1.small"
  node_config = module.controlplane.node_config
}

output "controlplane_ips" {
  value     = module.controlplane.controlplane_ips
  sensitive = true
}
