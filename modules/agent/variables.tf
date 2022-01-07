variable "node_config" {
  type = object({
    cluster_name       = string
    keypair_name       = string
    ssh_key_file       = string
    system_user        = string
    use_ssh_agent      = bool
    subnet_id          = string
    network_id         = string
    secgroup_id        = string
    config_drive       = bool
    floating_ip_pool   = string
    user_data          = string
    boot_from_volume   = bool
    boot_volume_size   = number
    availability_zones = list(string)
    bootstrap_server   = string
    rke2_token         = string
    registries_conf    = string
    bastion_host       = string
  })

}

variable "nodes_count" {
  type = string
}

variable "name_prefix" {
  type = string
}

variable "image_id" {
  type    = string
  default = ""
}

variable "image_name" {
  type    = string
  default = ""
}

variable "flavor_name" {
  type = string
}

variable "server_group_affinity" {
  type        = string
  default     = "soft-anti-affinity"
  description = "Server group affinity"
}

variable "assign_floating_ip" {
  type    = bool
  default = "false"
}

variable "rke2_version" {
  type    = string
  default = ""
}

variable "rke2_config" {
  type    = string
  default = ""
}

variable "do_upgrade" {
  type    = bool
  default = false
}

variable "boot_from_volume" {
  type = bool
}

variable "boot_volume_size" {
  type = number
}

variable "boot_volume_type" {
  type = string
}
