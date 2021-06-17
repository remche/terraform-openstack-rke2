variable "cluster_name" {
  type    = string
  default = "minimal"
}

variable "dns_servers" {
  type    = list(string)
  default = null
}
