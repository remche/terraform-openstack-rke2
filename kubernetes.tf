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
  source       = "Invicton-Labs/shell-resource/external"
  count        = var.output_kubernetes_config ? 1 : 0
  command_unix = "${local.ssh} ${var.system_user}@${module.server.floating_ip[0]} sudo KUBECONFIG=/etc/rancher/rke2/rke2-remote.yaml /var/lib/rancher/rke2/bin/kubectl config view --raw=true -o jsonpath='{.clusters[0].cluster.server}'"
  depends_on = [
    null_resource.write_kubeconfig
  ]
}

module "client_certificate" {
  source       = "Invicton-Labs/shell-resource/external"
  count        = var.output_kubernetes_config ? 1 : 0
  command_unix = "${local.ssh} ${var.system_user}@${module.server.floating_ip[0]} sudo KUBECONFIG=/etc/rancher/rke2/rke2-remote.yaml /var/lib/rancher/rke2/bin/kubectl config view --raw=true -o jsonpath='{.users[0].user.client-certificate-data}'"
  depends_on = [
    null_resource.write_kubeconfig
  ]
}

module "client_key" {
  source       = "Invicton-Labs/shell-resource/external"
  count        = var.output_kubernetes_config ? 1 : 0
  command_unix = "${local.ssh} ${var.system_user}@${module.server.floating_ip[0]} sudo KUBECONFIG=/etc/rancher/rke2/rke2-remote.yaml /var/lib/rancher/rke2/bin/kubectl config view --raw=true -o jsonpath='{.users[0].user.client-key-data}'"
  depends_on = [
    null_resource.write_kubeconfig
  ]
}

module "cluster_ca_certificate" {
  source       = "Invicton-Labs/shell-resource/external"
  count        = var.output_kubernetes_config ? 1 : 0
  command_unix = "${local.ssh} ${var.system_user}@${module.server.floating_ip[0]} sudo KUBECONFIG=/etc/rancher/rke2/rke2-remote.yaml /var/lib/rancher/rke2/bin/kubectl config view --raw=true -o jsonpath='{.clusters[0].cluster.certificate-authority-data}'"
  depends_on = [
    null_resource.write_kubeconfig
  ]
}
