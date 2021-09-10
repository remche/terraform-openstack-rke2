module "controlplane" {
  source           = "remche/rke2/openstack"
  cluster_name     = var.cluster_name
  dns_servers      = var.dns_servers
  write_kubeconfig = true
  image_name       = "ubuntu-20.04-focal-x86_64"
  flavor_name      = "cpuX2"
  public_net_name  = "dmz"
  rke2_config_file = "server.yaml"
  manifests_path   = "./manifests"
  # Fix for https://github.com/rancher/rke2/issues/1113
  additional_san = ["kubernetes.default.svc"]
}

module "worker" {
  source      = "remche/rke2/openstack//modules/agent"
  image_name  = "ubuntu-20.04-focal-x86_64"
  nodes_count = 2
  name_prefix = "worker"
  flavor_name = "cpuX2"
  node_config = module.controlplane.node_config
}
