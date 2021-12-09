####################
# Global variables #
####################

variable "cluster_name" {
  type        = string
  default     = "rke2"
  description = "Name of the cluster"
}

variable "ssh_keypair_name" {
  type        = string
  default     = null
  description = "SSH keypair name"
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
  default     = "true"
  description = "Whether to use ssh agent"
}

variable "write_kubeconfig" {
  type        = bool
  default     = "false"
  description = "Write kubeconfig file to disk"
}

variable "output_kubernetes_config" {
  type        = bool
  default     = "false"
  description = "Output Kubernetes config to state (for use with Kubernetes provider)"
}

######################
# Secgroup variables #
######################

variable "secgroup_rules" {
  type = list(any)
  default = [{ "source" = "0.0.0.0/0", "protocol" = "tcp", "port" = 22 },
    { "source" = "0.0.0.0/0", "protocol" = "tcp", "port" = 6443 },
    { "source" = "0.0.0.0/0", "protocol" = "tcp", "port" = 80 },
    { "source" = "0.0.0.0/0", "protocol" = "tcp", "port" = 443 }
  ]
  description = "Security group rules"
}

#####################
# Network variables #
#####################

variable "nodes_net_cidr" {
  type        = string
  default     = "193.48.86.0/24"
  description = "Neutron network CIDR"
}

variable "public_net_name" {
  type        = string
  description = "External network name"
}

variable "dns_servers" {
  type        = list(string)
  default     = null
  description = "DNS servers"
}

variable "dns_domain" {
  type        = string
  default     = null
  description = "DNS domain for DNS integration. DNS domain names must have a dot at the end"
}

##################
# Node variables #
##################

variable "image_id" {
  type        = string
  default     = ""
  description = "ID of image nodes (must fullfill [RKE2 requirements](https://docs.rke2.io/install/requirements/))"
}

variable "image_name" {
  type        = string
  default     = ""
  description = "ID of image nodes (must fullfill [RKE2 requirements](https://docs.rke2.io/install/requirements/))"
}

variable "nodes_count" {
  type        = number
  default     = 1
  description = "Number of server nodes (should be odd number...)"
}

variable "flavor_name" {
  type        = string
  description = "Server flavor name"
}

variable "server_group_affinity" {
  type        = string
  default     = "soft-anti-affinity"
  description = "Server server group affinity"
}

variable "agent_group_affinity" {
  type        = string
  default     = "soft-anti-affinity"
  description = "Agent server group affinity"
}

variable "nodes_config_drive" {
  type        = bool
  default     = "false"
  description = "Whether to use the config_drive feature to configure the instances"
}

variable "user_data_file" {
  type        = string
  default     = null
  description = "User data file to provide when launching the instance"
}

variable "boot_from_volume" {
  type        = bool
  default     = false
  description = "Boot nodes from volume"
}

variable "boot_volume_size" {
  type        = number
  default     = 20
  description = "The size of the boot volume"
}

variable "availability_zones" {
  type        = list(string)
  default     = []
  description = "The list of AZs to deploy nodes into"
}

variable "rke2_version" {
  type        = string
  default     = ""
  description = "RKE2 version"
}

variable "rke2_config_file" {
  type        = string
  default     = ""
  description = "RKE2 config file for servers"
}

variable "additional_san" {
  type        = list(string)
  default     = []
  description = "RKE2 additional SAN"
}

variable "manifests_path" {
  type        = string
  default     = ""
  description = "RKE2 addons manifests directory"
}

variable "do_upgrade" {
  type        = bool
  default     = false
  description = "Trigger upgrade provisioner"
}
