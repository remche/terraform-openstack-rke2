output "controlplane_ips" {
  value     = module.master.floating_ip
  sensitive = true
}

output "node_config" {
  value     = local.node_config
  sensitive = true
}
