module "controlplane" {
  source           = "yashani/rke2/openstack"
  write_kubeconfig = true
  image_name       = "ubuntu-20.04-docker-g4-cudnn-x86_64"
  flavor_name      = "m1.large-2d"
  dns_servers      = ["193.48.86.103", "193.48.86.224"]
  public_net_name  = "public"
  rke2_config_file = "server.yaml"
  manifests_path   = "./manifests"
  # Fix for https://github.com/rancher/rke2/issues/1113
  additional_san   = ["kubernetes.default.svc"]
}

module "worker" {
  source           = "yashani/rke2/openstack//modules/agent"
  image_name       = "ubuntu-20.04-docker-g4-cudnn-x86_64"
  nodes_count      = 2
  name_prefix      = "worker"
  flavor_name      = "g4.xlarge-4xmem"
  node_config      = module.controlplane.node_config
}
