locals {
  identity_service = [for entry in data.openstack_identity_auth_scope_v3.scope.service_catalog :
  entry if entry.type == "identity"][0]
  identity_endpoint = [for endpoint in local.identity_service.endpoints :
  endpoint if(endpoint.interface == "public" && endpoint.region == openstack_identity_application_credential_v3.rke2_csi.region)][0]

  os_cinder_b64 = base64gzip(templatefile("${path.root}/os_cinder.yaml.tpl", {
    auth_url   = local.identity_endpoint.url
    region     = local.identity_endpoint.region
    project_id = openstack_identity_application_credential_v3.rke2_csi.project_id
    app_id     = openstack_identity_application_credential_v3.rke2_csi.id
    app_secret = openstack_identity_application_credential_v3.rke2_csi.secret
  }))

  os_ccm_b64 = base64gzip(templatefile("${path.root}/os_ccm.yaml.tpl", {
    auth_url            = local.identity_endpoint.url
    region              = local.identity_endpoint.region
    project_id          = openstack_identity_application_credential_v3.rke2_csi.project_id
    app_id              = openstack_identity_application_credential_v3.rke2_csi.id
    app_secret          = openstack_identity_application_credential_v3.rke2_csi.secret
    floating_network_id = var.fip_net_id
    subnet_id           = module.controlplane.subnet_id
  }))

  containerd_config_b64 = filebase64("${path.root}/config.toml.tmpl")
}


data "openstack_identity_auth_scope_v3" "scope" {
  name = "auth_scope"
}

data "openstack_networking_subnet_v2" "nodes_subnet" {
  subnet_id = module.controlplane.subnet_id
}


resource "openstack_identity_application_credential_v3" "rke2_csi" {
  name = "${var.cluster_name}-csi-credentials"
}

resource "openstack_networking_secgroup_rule_v2" "nodeport" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 30000
  port_range_max    = 32768
  remote_ip_prefix  = data.openstack_networking_subnet_v2.nodes_subnet.cidr
  security_group_id = module.controlplane.node_config.secgroup_id
}


module "controlplane" {
  source           = "git::https://github.com/compendius/terraform-openstack-rke2.git"
  cluster_name     = var.cluster_name
  write_kubeconfig = true
  boot_from_volume = true
  boot_volume_size = var.master_volume_size
  boot_volume_type = var.master_volume_type
  image_name       = var.image_name
  flavor_name      = var.master_flavor_name
  public_net_name  = var.fip_net
  nodes_count      = var.num_masters
  manifests_path   = "./manifests"
  server_group_affinity = "affinity"
  containerd_config_file = local.containerd_config_b64
  rke2_config      = file("server.yaml")
  manifests_gzb64 = {
    "cinder-csi-plugin" : local.os_cinder_b64
    "openstack-controller-manager" : local.os_ccm_b64
  }
}
module "worker" {
  source           = "git::https://github.com/compendius/terraform-openstack-rke2.git//modules/agent"
  boot_from_volume = true
  boot_volume_size = var.worker_volume_size
  boot_volume_type = var.worker_volume_type
  image_name       = var.image_name
  nodes_count      = var.num_workers
  name_prefix      = "worker"
  containerd_config_file = local.containerd_config_b64
  flavor_name      = var.worker_flavor_name
  server_group_affinity = "affinity"
  node_config      = module.controlplane.node_config
}
