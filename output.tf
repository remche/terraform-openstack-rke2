output "controlplane_floating_ip" {
  value     = module.server.floating_ip
  sensitive = true
}

output "controlplane_internal_ip" {
  value     = module.server.floating_ip
  sensitive = true
}

output "node_config" {
  value     = local.node_config
  sensitive = true
}
