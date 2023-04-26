# The terraform.tfvars file for an example cluster, using three different kinds of instances 
# In order to use already existing networks, the var assign_floating_ip will be set to "false"

assign_floating_ip = "false"

cluster_name       = "my-cluster-name"
image_name         = "ubuntu-22.04"

flavor_name_controlplane = "l2.c2r4.100"
flavor_name_loadbalancer = "l2.c4r8.100"
flavor_name_worker       = "l2.c2r4.500"

existing_network_name_controlplane = "default"
existing_network_name_loadbalancer = "elasticip"
existing_network_name_worker       = "default"

existing_subnet_name_controlplane = "default-v4-nat"
existing_subnet_name_loadbalancer = "elasticip-v4"
existing_subnet_name_worker       = "default-v4-nat"

write_kubeconfig = "true"
ssh_key_file     = "./id_rsa-foo"
