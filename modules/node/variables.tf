variable "node_depends_on" {
  type    = any
  default = null
}

variable "nodes_count" {
  type = string
}

variable "name_prefix" {
  type = string
}

variable "image_name" {
  type = string
}

variable "flavor_name" {
  type = string
}

variable "keypair_name" {
  type = string
}

variable "network_name" {
  type = string
}

variable "config_drive" {
  type = bool
}

variable "server_affinity" {
  type = string
}

variable "secgroup_name" {
  type = string
}

variable "assign_floating_ip" {
  type    = bool
  default = "false"
}

variable "floating_ip_pool" {
  type    = string
}

variable "user_data" {
  type = string
}

variable "boot_from_volume" {
  type = bool
}

variable "boot_volume_size" {
  type = number
}

variable "availability_zones" {
  type = list(string)
}

variable "bootstrap_server" {
  type    = string
  default = ""
}

variable "is_master" {
  type    = bool
  default = true
}
