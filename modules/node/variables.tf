variable "node_depends_on" {
  type    = any
  default = null
}

variable "nodes_count" {
  type = number
}

variable "cluster_name" {
  type = string
}

variable "name_prefix" {
  type = string
}

variable "image_id" {
  type = string
}

variable "image_name" {
  type = string
}

variable "instance_tags" {
  type    = list(string)
  default = []
}

variable "flavor_name" {
  type = string
}

variable "keypair_name" {
  type = string
}

variable "ssh_key_file" {
  type        = string
  default     = "~/.ssh/id_rsa"
  description = "Local path to SSH key"
}

variable "system_user" {
  type        = string
  default     = "ubuntu"
  description = "Default OS image user"
}

variable "use_ssh_agent" {
  type        = bool
  default     = true
  description = "Whether to use ssh agent"
}

variable "network_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "config_drive" {
  type = bool
}

variable "server_affinity" {
  type = string
}

variable "secgroup_id" {
  type = string
}

variable "assign_floating_ip" {
  type    = bool
  default = false
}

variable "floating_ip_pool" {
  type = string
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

variable "boot_volume_type" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "rke2_version" {
  type = string
}

variable "rke2_config" {
  type    = string
  default = ""
}

variable "containerd_config_file" {
  type = string
}

variable "registries_conf" {
  type = string
}

variable "bootstrap_server" {
  type    = string
  default = ""
}

variable "bastion_host" {
  type    = string
  default = ""
}

variable "is_server" {
  type    = bool
  default = true
}

variable "rke2_token" {
  type    = string
  default = ""
}

variable "additional_san" {
  type        = list(string)
  default     = []
  description = "RKE additional SAN"
}

variable "manifests_path" {
  type        = string
  default     = ""
  description = "RKE2 addons manifests directory"
}

variable "manifests_gzb64" {
  type    = map(string)
  default = {}
}

variable "do_upgrade" {
  type = bool
}
