output "server_ip" {
  description = "Server floating IP"
  value       = module.controlplane.floating_ip[0]
  sensitive   = true
}
