apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: openstack-cloud-controller-manager
  namespace: kube-system
spec:
  chart: openstack-cloud-controller-manager
  repo: https://kubernetes.github.io/cloud-provider-openstack
  targetNamespace: kube-system
  bootstrap: True
  valuesContent: |-
    cloudConfig:
      global:
        auth-url: ${auth_url}
        application-credential-id: ${app_id}
        application-credential-secret: ${app_secret}
        region: ${region}
        tenant-id: ${project_id}
      loadBalancer:
        floating-network-id: ${floating_network_id}
        floating-subnet-id: ${floating_subnet_id}
        subnet-id: ${subnet_id}