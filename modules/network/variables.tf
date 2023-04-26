variable "assign_floating_ip" {
  description = "Boolean that determines whether or not to create new networks in OpenStack"
  type        = bool
}

variable "network_id" {
  type = string
  description = "OpenStack network ID"
}

variable "subnet_id" {
  type = string
  description = "OpenStack subnet ID"
}

variable "existing_network_name" {
  type        = string
  description = "The name of an existing network to use"
  default     = null
}

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
