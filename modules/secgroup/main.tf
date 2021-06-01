resource "openstack_networking_secgroup_v2" "secgroup" {
  name        = "${var.name_prefix}-secgroup"
  description = "Security group for RKE"
}

resource "openstack_networking_secgroup_rule_v2" "default_rule" {
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_group_id   = openstack_networking_secgroup_v2.secgroup.id
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
}

#resource "openstack_networking_secgroup_rule_v2" "tunnel_rule" {
  #direction         = "ingress"
  #ethertype         = "IPv4"
  #remote_ip_prefix  = "${var.bastion_host}/32"
  #security_group_id = openstack_networking_secgroup_v2.secgroup.id
#}

resource "openstack_networking_secgroup_rule_v2" "rules" {
  for_each          = {
    for rule in var.rules :
    format("%s-%s-%s", rule["source"], rule["protocol"], rule["port"]) => rule
  }
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = each.value.protocol
  port_range_min    = each.value.port
  port_range_max    = each.value.port
  remote_ip_prefix  = each.value.source
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
}
