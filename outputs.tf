output "floating_ip" {
  value       = module.server.floating_ip
  sensitive   = true
  description = "Nodes floating IP"
}

output "internal_ip" {
  value       = module.server.internal_ip
  sensitive   = true
  description = "Nodes internal IP"
}

output "node_config" {
  value       = local.node_config
  sensitive   = true
  description = "Nodes config"
}

output "subnet_id" {
  value       = module.network.nodes_subnet_id
  sensitive   = true
  description = "Nodes Subnet ID"
}

output "kubernetes_config" {
  value = var.output_kubernetes_config ? {
    host                   = module.host[0].stdout
    client_certificate     = module.client_certificate[0].stdout
    client_key             = module.client_key[0].stdout
    cluster_ca_certificate = module.cluster_ca_certificate[0].stdout
  } : {}
  sensitive   = true
  description = "Kubernetes config to feed Kubernetes or Helm provider"
}
