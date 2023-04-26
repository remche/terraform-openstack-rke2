variable "existing_network_name" {
  type        = string
  description = "Name of an existing network"
  default     = "default"
}

variable "existing_network_name_controlplane" {
  type        = string
  description = "Existing OpenStack network to use for the controlplane nodes"
}

variable "existing_subnet_name_controlplane" {
  type        = string
  description = "Existing OpenStack network to use for the controlplane nodes"
}

variable "existing_network_name_worker" {
  type        = string
  description = "Existing OpenStack network to use for the worker nodes"
}

variable "existing_subnet_name_worker" {
  type        = string
  description = "Existing OpenStack network to use for the worker nodes"
}

variable "existing_network_name_loadbalancer" {
  type        = string
  description = "Existing OpenStack network to use for the loadbalancer nodes"
}

variable "existing_subnet_name_loadbalancer" {
  type        = string
  description = "Existing OpenStack network to use for the loadbalancer nodes"
}

variable "flavor_name_controlplane" {
  type        = string
  description = "OpenStack flavor to use for the controlplane nodes"
}

variable "flavor_name_worker" {
  type        = string
  description = "OpenStack flavor to use for the worker nodes"
}

variable "flavor_name_loadbalancer" {
  type        = string
  description = "OpenStack flavor to use for the loadbalancer nodes"
}

variable "assign_floating_ip" {
  description = "Assign a floating IP to the server"
  type        = bool
  default     = false
}

variable "existing_network_id_controlplane" {
  type        = string
  description = "Existing OpenStack network ID for the controlplane nodes"
  default     = null
}

variable "existing_subnet_id_controlplane" {
  type        = list(string)
  description = "OpenStack subnet ID for the controlplane nodes"
  default     = null
}

variable "existing_network_id_loadbalancer" {
  type        = string
  description = "Existing OpenStack network ID for the controlplane nodes"
  default     = null
}

variable "existing_subnet_id_loadbalancer" {
  type        = string
  description = "OpenStack subnet ID for the controlplane nodes"
  default     = null
}

variable "existing_network_id_worker" {
  type        = string
  description = "Existing OpenStack network ID for the controlplane nodes"
  default     = null
}

variable "existing_subnet_id_worker" {
  type        = string
  description = "OpenStack subnet ID for the controlplane nodes"
  default     = null
}

variable "network_id" {
  type        = string
  description = "OpenStack network ID"
  default     = null
}

variable "subnet_id" {
  type        = string
  description = "OpenStack subnet ID"
  default     = null
}

variable "cluster_name" {
  type = string
}

variable "write_kubeconfig" {
  type    = bool
  default = false
}

variable "image_name" {
  type    = string
  default = "ubuntu-22.04"
}

variable "flavor_name" {
  type    = string
  default = "l2.c4r8.100"
}

variable "ssh_key_file" {
  type    = string
  default = "./id_rsa-foo"
}
