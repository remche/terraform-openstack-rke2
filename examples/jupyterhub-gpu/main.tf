module "controlplane" {
  source           = "remche/rke2/openstack"
  write_kubeconfig = true
  image_name       = "fg-services-ubuntu-20.04-x86_64.raw"
  flavor_name      = "m1.large-2d"
  public_net_name  = "public"
  rke2_config_file = "server.yaml"
  manifests_path   = "./manifests"
  # Fix for https://github.com/rancher/rke2/issues/1113
  additional_san = ["kubernetes.default.svc"]
}

module "worker" {
  source      = "remche/rke2/openstack//modules/agent"
  image_name  = "fg-services-ubuntu-20.04-x86_64.raw"
  nodes_count = 1
  name_prefix = "worker"
  flavor_name = "g4.xlarge-4xmem"
  node_config = module.controlplane.node_config
}
