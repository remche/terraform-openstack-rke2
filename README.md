# terraform-openstack-rke2
[![Terraform Registry](https://img.shields.io/badge/terraform-registry-blue.svg)](https://registry.terraform.io/modules/remche/rke2/openstack)
[![test-fast](https://github.com/remche/terraform-openstack-rke2/actions/workflows/test-fast.yaml/badge.svg)](https://github.com/remche/terraform-openstack-rke2/actions/workflows/test-fast.yaml)
[![test-full](https://github.com/remche/terraform-openstack-rke2/actions/workflows/test-full.yaml/badge.svg)](https://github.com/remche/terraform-openstack-rke2/actions/workflows/test-full.yaml)


[Terraform](https://www.terraform.io/) module to deploy [Kubernetes](https://kubernetes.io) with [RKE2](https://docs.rke2.io/) on [OpenStack](https://www.openstack.org/).

Unlike [RKE version](https://github.com/remche/terraform-openstack-rke) this module is not opinionated and let you configure everything via [RKE2 configuration file](https://docs.rke2.io/install/install_options/install_options/#configuring-rke2-server-nodes).

## Prerequisites

- [Terraform](https://www.terraform.io/) 0.13+
- [OpenStack](https://docs.openstack.org/zh_CN/user-guide/common/cli-set-environment-variables-using-openstack-rc.html) environment properly sourced
- A Openstack image fullfiling [RKE2 requirements](https://docs.rke2.io/install/requirements/) and featuring curl
- At least one Openstack floating IP

## Features

- HA controlplane
- Multiple agent node pools
- Upgrade mechanism

## Examples

See [examples](./examples) directory.


## Documentation

See [USAGE.md](USAGE.md) for all available options.

### Keypair

You can either specify a ssh key file to generate new keypair via `ssh_key_file` (default) or specify already existent keypair via `ssh_keypair_name`.

> :warning: Default config will try to use  [ssh agent](https://linux.die.net/man/1/ssh-agent) for ssh connections to the nodes. Add `use_ssh_agent = false` if you don't use it.

### Secgroup

You can define your own rules (e.g. limiting port 22 and 6443 to admin box).

```hcl
secgroup_rules      = [ { "source" = "x.x.x.x", "protocol" = "tcp", "port" = 22 },
                        { "source" = "x.x.x.x", "protocol" = "tcp", "port" = 6443 },
                        { "source" = "0.0.0.0/0", "protocol" = "tcp", "port" = 80 },
                        { "source" = "0.0.0.0/0", "protocol" = "tcp", "port" = 443}
                      ]
```

### Nodes affinity

You can set [affinity policy](https://www.terraform.io/docs/providers/openstack/r/compute_servergroup_v2.html#policies) for controlplane and each nodes pool `server_group_affinity`. Default is `soft-anti-affinity`.

> :warning: `soft-anti-affinity` and `soft-affinity` needs Compute service API 2.15 or above.

## Boot from volume

Some providers require to boot the instances from an attached boot volume instead of the nova ephemeral volume.
To enable this feature, provide the variables to the config file. You can use  different value for server and agent nodes.

```hcl
boot_from_volume = true
boot_volume_size = 20
boot_volume_type = "rbd-1"
```

### Kubernetes version

You can specify rke2 version with `rke2_version` variables. Refer to RKE2 supported version.

Upgrade by setting the new version and `do_upgrade = true`. It will upgrade the nodes one-by-one. Upgrade the controlplane first, then the nodes pools.

### Addons

Set the `manifests_path` variable to point out the directory containing your [manifests and HelmChart](https://docs.rke2.io/helm.html#automatically-deploying-manifests-and-helm-charts) (see [JupyterHub example](./examples/jupyterhub/)).

If you need a template step for your manifests, you can use `manifests_gzb64` (see [cinder-csi-plugin example](./examples/cinder-csi-plugin)).

> :warning: Modifications made to manifests after cluster deployement wont have any effect.

### Downscale

You need to manually drain and remove node before downscaling a pool nodes.

### Usage with [Terraform Kubernetes Provider](https://www.terraform.io/docs/providers/kubernetes/index.html) and [Helm Provider](https://www.terraform.io/docs/providers/helm/index.html)

You can tell the module to output kubernetes config by setting `output_kubernetes_config = true`.

> :warning: **Interpolating provider variables from module output is not the recommended way to achieve integration**. See [here](https://www.terraform.io/docs/providers/kubernetes/index.html) and [here](https://www.terraform.io/docs/configuration/providers.html#provider-configuration).
>
> Use of a data sources is recommended.

(Not recommended) You can use this module to populate [Terraform Kubernetes Provider](https://www.terraform.io/docs/providers/kubernetes/index.html) :

```hcl
provider "kubernetes" {
  host     = module.controlplane.kubernetes_config.host
  client_certificate     = module.controlplane.kubernetes_config.client_certificate
  client_key             = module.controlplane.kubernetes_config.client_key
  cluster_ca_certificate = module.controlplane.kubernetes_config.cluster_ca_certificate
}
```

Recommended way needs two `apply` operations, and setting the proper `terraform_remote_state` data source :

```hcl
provider "kubernetes" {
  host     = data.terraform_remote_state.rke2.outputs.kubernetes_config.host
  client_certificate     = data.terraform_remote_state.rke2.outputs.kubernetes_config.client_certificate
  client_key             = data.terraform_remote_state.rke2.outputs.kubernetes_config.client_key
  cluster_ca_certificate = data.terraform_remote_state.rke2.outputs.kubernetes_config.cluster_ca_certificate
}
```
