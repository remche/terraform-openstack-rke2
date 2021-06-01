module "controlplane" {
  source      = "./.."
  dns_domain  = "u-ga.fr."
  dns_servers = ["152.77.1.22", "195.83.24.30"]
  image_name      = "ubuntu-20.04-focal-x86_64+rke2"
  flavor_name = "m1.small"
  public_net_name = "public"
  secgroup_rules = [{ "source" = "152.77.119.207/32", "protocol" = "tcp", "port" = 22 },
    { "source" = "152.77.119.207/32", "protocol" = "icmp", port = 0 },
    { "source" = "147.171.168.176/32", "protocol" = "icmp", port = 0 },
    { "source" = "152.77.119.207/32", "protocol" = "tcp", "port" = 6443 },
    { "source" = "147.171.168.176/32", "protocol" = "tcp", "port" = 22 },
    { "source" = "147.171.168.176/32", "protocol" = "tcp", "port" = 6443 },
    { "source" = "0.0.0.0/0", "protocol" = "tcp", "port" = 80 },
    { "source" = "0.0.0.0/0", "protocol" = "tcp", "port" = 443 }
  ]
}

module "blue_node" {
  source      = "./..//modules/worker"
  image_name  = "ubuntu-20.04-focal-x86_64+rke2"
  nodes_count = 1
  name_prefix = "blue"
  flavor_name = "m1.small"
  node_config = module.controlplane.node_config
}

module "green_node" {
  source      = "./..//modules/worker"
  image_name  = "ubuntu-20.04-focal-x86_64+rke2"
  nodes_count = 1
  name_prefix = "green"
  flavor_name = "m1.small"
  node_config = module.controlplane.node_config
}
