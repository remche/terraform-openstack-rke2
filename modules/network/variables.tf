variable "network_name" {
  type = string
}

variable "subnet_name" {
  type = string
}

variable "router_name" {
  type = string
}

variable "nodes_net_cidr" {
  type = string
}

variable "public_net_name" {
  type = string
}

variable "dns_servers" {
  type = list(string)
}

variable "dns_domain" {
  type = string
}
