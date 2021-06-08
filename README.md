# terraform-openstack-rke2
[![Terraform Registry](https://img.shields.io/badge/terraform-registry-blue.svg)](https://registry.terraform.io/modules/remche/rke2/openstack)

[Terraform](https://www.terraform.io/) module to deploy [Kubernetes](https://kubernetes.io) with [RKE2](https://docs.rke2.io/) on [OpenStack](https://www.openstack.org/).

Unlike [RKE version](https://github.com/remche/terraform-openstack-rke) this module is not opinionated and let you configure everything via [RKE2 configuration file](https://docs.rke2.io/install/install_options/install_options/#configuring-rke2-server-nodes).

## Prerequisites

- [Terraform](https://www.terraform.io/) 0.13+
- [OpenStack](https://docs.openstack.org/zh_CN/user-guide/common/cli-set-environment-variables-using-openstack-rc.html) environment properly sourced.
- A Openstack image fullfiling [RKE2 requirements](https://docs.rke2.io/install/requirements/).
- At least one Openstack floating IP.

## Features

- HA controlplane
- Multiple agent node pools
- Upgrade

More soon... See [USAGE](./USAGE.md) and [examples](./examples) dir if you feel adventurous !
