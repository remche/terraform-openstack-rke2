output "keypair_name" {
  value       = module.keypair.keypair_name
  description = "The name of the keypair used for nodes"
  sensitive   = "true"
}

output "node_config" {
  value     = local.node_config
  sensitive = true
}
