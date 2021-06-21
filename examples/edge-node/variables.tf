variable "cluster_name" {
  type    = string
  default = "edge-node"
}

variable "dns_servers" {
  type    = list(string)
  default = null
}
