output "keypair_name" {
  value       = module.keypair.keypair_name
  description = "The name of the keypair used for nodes"
  sensitive   = "true"
}

output "master_nodes" {
  value       = module.master.nodes
  description = "The master nodes"
}

output "nodes_subnet" {
  value       = module.network.nodes_subnet
  description = "The nodes subnet"
}

output "node_config" {
  value = local.node_config
  sensitive = true
}
