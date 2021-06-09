module "controlplane" {
  source           = "remche/rke2/openstack"
  write_kubeconfig = true
  image_name       = "ubuntu-20.04-focal-x86_64"
  flavor_name      = "m1.small"
  public_net_name  = "public"
}
