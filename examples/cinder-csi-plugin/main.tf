locals {
  identity_service = [for entry in data.openstack_identity_auth_scope_v3.scope.service_catalog :
  entry if entry.type == "identity"][0]
  identity_endpoint = [for endpoint in local.identity_service.endpoints :
  endpoint if(endpoint.interface == "public" && endpoint.region == openstack_identity_application_credential_v3.rke2_csi.region)][0]
  manifests_b64 = base64gzip(templatefile("${path.root}/cloud-config.yaml.tpl", {
    auth_url   = local.identity_endpoint.url
    region     = local.identity_endpoint.region
    project_id = openstack_identity_application_credential_v3.rke2_csi.project_id
    app_id     = openstack_identity_application_credential_v3.rke2_csi.id
    app_secret = openstack_identity_application_credential_v3.rke2_csi.secret
  }))
}

data "openstack_identity_auth_scope_v3" "scope" {
  name = "auth_scope"
}

resource "openstack_identity_application_credential_v3" "rke2_csi" {
  name = "rke2-csi-credentials"
}

module "controlplane" {
  source           = "remche/rke2/openstack"
  cluster_name     = var.cluster_name
  write_kubeconfig = true
  image_name       = "ubuntu-20.04-focal-x86_64"
  flavor_name      = "m1.small"
  public_net_name  = "public"
  manifests_gzb64  = { "cinder-csi-plugin" : local.manifests_b64 }
}
