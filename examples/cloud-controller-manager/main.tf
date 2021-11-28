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
    floating_network_id = "ee54f79e-d33a-4866-8df0-4a4576d70243"
    floating_subnet_id  = "80a79c2a-b462-478e-9b92-f022fe799535"
    subnet_id           = "78abbf30-e895-4eee-a457-dbfa3efb838d"
  }))
}

data "openstack_identity_auth_scope_v3" "scope" {
  name = "auth_scope"
}

resource "openstack_identity_application_credential_v3" "rke2_csi" {
  name = "${var.cluster_name}-csi-credentials"
}

module "controlplane" {
  source           = "remche/rke2/openstack"
  cluster_name     = var.cluster_name
  write_kubeconfig = true
  image_name       = "Ubuntu-20.04"
  flavor_name      = "ec1.medium"
  public_net_name  = "external"
  nodes_count      = 1
  rke2_config_file = "rke2_config.yaml"
  manifests_gzb64 = {
    "cinder-csi-plugin" : local.os_cinder_b64
    "openstack-controller-manager" : local.os_ccm_b64
  }
}
