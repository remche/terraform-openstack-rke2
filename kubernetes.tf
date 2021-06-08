module "host" {
  source  = "matti/resource/shell"
  count   = var.output_kubernetes_config ? 1 : 0
  command = "${local.ssh} ${var.system_user}@${module.server.floating_ip[0]} sudo KUBECONFIG=/etc/rancher/rke2/rke2-remote.yaml /var/lib/rancher/rke2/bin/kubectl config view --raw=true -o jsonpath='{.clusters[0].cluster.server}'"
}

module "client_certificate" {
  source  = "matti/resource/shell"
  count   = var.output_kubernetes_config ? 1 : 0
  command = "${local.ssh} ${var.system_user}@${module.server.floating_ip[0]} sudo KUBECONFIG=/etc/rancher/rke2/rke2-remote.yaml /var/lib/rancher/rke2/bin/kubectl config view --raw=true -o jsonpath='{.users[0].user.client-certificate-data}'"
}

module "client_key" {
  source  = "matti/resource/shell"
  count   = var.output_kubernetes_config ? 1 : 0
  command = "${local.ssh} ${var.system_user}@${module.server.floating_ip[0]} sudo KUBECONFIG=/etc/rancher/rke2/rke2-remote.yaml /var/lib/rancher/rke2/bin/kubectl config view --raw=true -o jsonpath='{.users[0].user.client-key-data}'"
}

module "cluster_ca_certificate" {
  source  = "matti/resource/shell"
  count   = var.output_kubernetes_config ? 1 : 0
  command = "${local.ssh} ${var.system_user}@${module.server.floating_ip[0]} sudo KUBECONFIG=/etc/rancher/rke2/rke2-remote.yaml /var/lib/rancher/rke2/bin/kubectl config view --raw=true -o jsonpath='{.clusters[0].cluster.certificate-authority-data}'"
}

output "kubernetes_config" {
  value = var.output_kubernetes_config ? {
    host                   = module.host[0].stdout
    client_certificate     = module.client_certificate[0].stdout
    client_key             = module.client_key[0].stdout
    cluster_ca_certificate = module.cluster_ca_certificate[0].stdout
  } : {}
  sensitive = true
}
