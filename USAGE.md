# Usage

<!--- BEGIN_TF_DOCS --->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=0.13.1 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >=1.4.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >=2.1.2 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >=3.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_local"></a> [local](#provider\_local) | >=1.4.0 |
| <a name="provider_null"></a> [null](#provider\_null) | >=2.1.2 |
| <a name="provider_random"></a> [random](#provider\_random) | >=3.1.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_client_certificate"></a> [client\_certificate](#module\_client\_certificate) | matti/resource/shell | 1.5.0 |
| <a name="module_client_key"></a> [client\_key](#module\_client\_key) | matti/resource/shell | 1.5.0 |
| <a name="module_cluster_ca_certificate"></a> [cluster\_ca\_certificate](#module\_cluster\_ca\_certificate) | matti/resource/shell | 1.5.0 |
| <a name="module_host"></a> [host](#module\_host) | matti/resource/shell | 1.5.0 |
| <a name="module_keypair"></a> [keypair](#module\_keypair) | ./modules/keypair | n/a |
| <a name="module_network"></a> [network](#module\_network) | ./modules/network | n/a |
| <a name="module_secgroup"></a> [secgroup](#module\_secgroup) | ./modules/secgroup | n/a |
| <a name="module_server"></a> [server](#module\_server) | ./modules/node | n/a |

## Resources

| Name | Type |
|------|------|
| [local_file.tmpdirfile](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [null_resource.write_kubeconfig](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_string.rke2_token](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_san"></a> [additional\_san](#input\_additional\_san) | RKE2 additional SAN | `list(string)` | `[]` | no |
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | The list of AZs to deploy nodes into | `list(string)` | `[]` | no |
| <a name="input_boot_from_volume"></a> [boot\_from\_volume](#input\_boot\_from\_volume) | Boot nodes from volume | `bool` | `false` | no |
| <a name="input_boot_volume_size"></a> [boot\_volume\_size](#input\_boot\_volume\_size) | The size of the boot volume | `number` | `20` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the cluster | `string` | `"rke2"` | no |
| <a name="input_dns_domain"></a> [dns\_domain](#input\_dns\_domain) | DNS domain for DNS integration. DNS domain names must have a dot at the end | `string` | `null` | no |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | DNS servers | `list(string)` | `null` | no |
| <a name="input_do_upgrade"></a> [do\_upgrade](#input\_do\_upgrade) | Trigger upgrade provisioner | `bool` | `false` | no |
| <a name="input_flavor_name"></a> [flavor\_name](#input\_flavor\_name) | Server flavor name | `string` | n/a | yes |
| <a name="input_image_id"></a> [image\_id](#input\_image\_id) | ID of image nodes (must fullfill [RKE2 requirements](https://docs.rke2.io/install/requirements/)) | `string` | `""` | no |
| <a name="input_image_name"></a> [image\_name](#input\_image\_name) | ID of image nodes (must fullfill [RKE2 requirements](https://docs.rke2.io/install/requirements/)) | `string` | `""` | no |
| <a name="input_manifests_gzb64"></a> [manifests\_gzb64](#input\_manifests\_gzb64) | RKE2 addons manifests in gz+b64 in the form { "addon\_name": "gzb64\_manifests" } | `map(string)` | `{}` | no |
| <a name="input_manifests_path"></a> [manifests\_path](#input\_manifests\_path) | RKE2 addons manifests directory | `string` | `""` | no |
| <a name="input_nodes_config_drive"></a> [nodes\_config\_drive](#input\_nodes\_config\_drive) | Whether to use the config\_drive feature to configure the instances | `bool` | `"false"` | no |
| <a name="input_nodes_count"></a> [nodes\_count](#input\_nodes\_count) | Number of server nodes (should be odd number...) | `number` | `1` | no |
| <a name="input_nodes_net_cidr"></a> [nodes\_net\_cidr](#input\_nodes\_net\_cidr) | Neutron network CIDR | `string` | `"192.168.42.0/24"` | no |
| <a name="input_output_kubernetes_config"></a> [output\_kubernetes\_config](#input\_output\_kubernetes\_config) | Output Kubernetes config to state (for use with Kubernetes provider) | `bool` | `"false"` | no |
| <a name="input_public_net_name"></a> [public\_net\_name](#input\_public\_net\_name) | External network name | `string` | n/a | yes |
| <a name="input_registries_conf"></a> [registries\_conf](#input\_registries\_conf) | Containerd registries config in gz+b64 | `string` | `""` | no |
| <a name="input_rke2_config"></a> [rke2\_config](#input\_rke2\_config) | RKE2 config contents for servers | `string` | `""` | no |
| <a name="input_rke2_version"></a> [rke2\_version](#input\_rke2\_version) | RKE2 version | `string` | `""` | no |
| <a name="input_secgroup_rules"></a> [secgroup\_rules](#input\_secgroup\_rules) | Security group rules | `list(any)` | <pre>[<br>  {<br>    "port": 22,<br>    "protocol": "tcp",<br>    "source": "0.0.0.0/0"<br>  },<br>  {<br>    "port": 6443,<br>    "protocol": "tcp",<br>    "source": "0.0.0.0/0"<br>  },<br>  {<br>    "port": 80,<br>    "protocol": "tcp",<br>    "source": "0.0.0.0/0"<br>  },<br>  {<br>    "port": 443,<br>    "protocol": "tcp",<br>    "source": "0.0.0.0/0"<br>  }<br>]</pre> | no |
| <a name="input_server_group_affinity"></a> [server\_group\_affinity](#input\_server\_group\_affinity) | Server group affinity | `string` | `"soft-anti-affinity"` | no |
| <a name="input_ssh_key_file"></a> [ssh\_key\_file](#input\_ssh\_key\_file) | Local path to SSH key | `string` | `"~/.ssh/id_rsa"` | no |
| <a name="input_ssh_keypair_name"></a> [ssh\_keypair\_name](#input\_ssh\_keypair\_name) | SSH keypair name | `string` | `null` | no |
| <a name="input_system_user"></a> [system\_user](#input\_system\_user) | Default OS image user | `string` | `"ubuntu"` | no |
| <a name="input_use_ssh_agent"></a> [use\_ssh\_agent](#input\_use\_ssh\_agent) | Whether to use ssh agent | `bool` | `"true"` | no |
| <a name="input_user_data_file"></a> [user\_data\_file](#input\_user\_data\_file) | User data file to provide when launching the instance | `string` | `null` | no |
| <a name="input_write_kubeconfig"></a> [write\_kubeconfig](#input\_write\_kubeconfig) | Write kubeconfig file to disk | `bool` | `"false"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_floating_ip"></a> [floating\_ip](#output\_floating\_ip) | Nodes floating IP |
| <a name="output_internal_ip"></a> [internal\_ip](#output\_internal\_ip) | Nodes internal IP |
| <a name="output_kubernetes_config"></a> [kubernetes\_config](#output\_kubernetes\_config) | Kubernetes config to feed Kubernetes or Helm provider |
| <a name="output_node_config"></a> [node\_config](#output\_node\_config) | Nodes config |
| <a name="output_subnet_id"></a> [subnet\_id](#output\_subnet\_id) | Nodes Subnet ID |

<!--- END_TF_DOCS --->

