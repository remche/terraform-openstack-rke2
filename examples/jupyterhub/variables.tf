variable "cluster_name" {
  type    = string
  default = "jupyterhub"
}

variable "dns_servers" {
  type    = list(string)
  default = null
}
