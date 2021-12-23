resource "null_resource" "write_kubeconfig" {
  count = var.write_kubeconfig ? 1 : 0

  connection {
    host        = module.server.floating_ip[0]
    user        = var.system_user
    private_key = var.use_ssh_agent ? null : file(var.ssh_key_file)
    agent       = var.use_ssh_agent
  }

  provisioner "remote-exec" {
    inline = ["until (grep ${var.cluster_name} /etc/rancher/rke2/rke2-remote.yaml >/dev/null 2>&1); do echo Waiting for rke2 to start && sleep 10; done;"]
  }

  provisioner "local-exec" {
    command = var.use_ssh_agent ? "${local.scp} ${local.remote_rke2_yaml} rke2.yaml" : "${local.scp} -i ${var.ssh_key_file} ${local.remote_rke2_yaml} rke2.yaml"
  }
}

module "host" {
  source  = "matti/resource/shell"
  version = "1.5.0"
  count   = var.output_kubernetes_config ? 1 : 0
  command = "${local.ssh} ${var.system_user}@${module.server.floating_ip[0]} sudo KUBECONFIG=/etc/rancher/rke2/rke2-remote.yaml /var/lib/rancher/rke2/bin/kubectl config view --raw=true -o jsonpath='{.clusters[0].cluster.server}'"
}

module "client_certificate" {
  source  = "matti/resource/shell"
  version = "1.5.0"
  count   = var.output_kubernetes_config ? 1 : 0
  command = "${local.ssh} ${var.system_user}@${module.server.floating_ip[0]} sudo KUBECONFIG=/etc/rancher/rke2/rke2-remote.yaml /var/lib/rancher/rke2/bin/kubectl config view --raw=true -o jsonpath='{.users[0].user.client-certificate-data}'"
}

module "client_key" {
  source  = "matti/resource/shell"
  version = "1.5.0"
  count   = var.output_kubernetes_config ? 1 : 0
  command = "${local.ssh} ${var.system_user}@${module.server.floating_ip[0]} sudo KUBECONFIG=/etc/rancher/rke2/rke2-remote.yaml /var/lib/rancher/rke2/bin/kubectl config view --raw=true -o jsonpath='{.users[0].user.client-key-data}'"
}

module "cluster_ca_certificate" {
  source  = "matti/resource/shell"
  version = "1.5.0"
  count   = var.output_kubernetes_config ? 1 : 0
  command = "${local.ssh} ${var.system_user}@${module.server.floating_ip[0]} sudo KUBECONFIG=/etc/rancher/rke2/rke2-remote.yaml /var/lib/rancher/rke2/bin/kubectl config view --raw=true -o jsonpath='{.clusters[0].cluster.certificate-authority-data}'"
}
