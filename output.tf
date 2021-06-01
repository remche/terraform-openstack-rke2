output "keypair_name" {
  value       = module.keypair.keypair_name
  description = "The name of the keypair used for nodes"
  sensitive   = "true"
}

output "master_nodes" {
  value       = module.master.nodes
  description = "The master nodes"
}

output "worker_nodes" {
  value       = module.worker.nodes
  description = "The worker nodes"
}

output "nodes_subnet" {
  value       = module.network.nodes_subnet
  description = "The nodes subnet"
}
