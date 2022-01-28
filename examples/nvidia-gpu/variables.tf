variable "cluster_name" {
  type    = string
  default = "os-gpu"
}

variable "image_name" {
  type    = string
  default = "ubuntu2004"
}

variable "master_flavor_name" {
  type    = string
  default = "m1.medium"
}

variable "master_volume_type" {
  type    = string
  default = "rbd-2-ssd"
}

variable "worker_volume_type" {
  type    = string
  default = "rbd-1"
}

variable "master_volume_size" {
  type    = number
  default = 40
}

variable "worker_volume_size" {
  type    = number
  default = 80
}

variable "worker_flavor_name" {
  type    = string
  default = "m1.medium"
}

variable "fip_net" {
  type    = string
  default = "public"
}

variable "fip_net_id" {
  type    = string
  default = "9948edde-640b-482b-a6bc-ad1466007786"
}

variable "num_masters" {
  type    = string
  default = "1"
}

variable "num_workers" {
  type    = string
  default = "1"
}
