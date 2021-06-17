variable "cluster_name" {
  type    = string
  default = "blue-green"
}

variable "dns_servers" {
  type    = list(string)
  default = null
}
