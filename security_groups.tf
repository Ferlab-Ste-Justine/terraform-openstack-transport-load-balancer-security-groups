locals {
    restricted_ports = flatten([for restricted_port in var.restricted_ports: [
        for group_id in restricted_port.group_ids: {
            port = restricted_port.port
            group_id = group_id
        }
    ]])
}

resource "openstack_networking_secgroup_v2" "transport_load_balancer" {
  name                 = var.load_balancer_group_name
  description          = "Security group for transport load balancers"
  delete_default_rules = true
}

//Allow all outbound traffic from transport load balancers
resource "openstack_networking_secgroup_rule_v2" "transport_load_balancer_outgoing_v4" {
  direction         = "egress"
  ethertype         = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.transport_load_balancer.id
}

resource "openstack_networking_secgroup_rule_v2" "transport_load_balancer_outgoing_v6" {
  direction         = "egress"
  ethertype         = "IPv6"
  security_group_id = openstack_networking_secgroup_v2.transport_load_balancer.id
}

//Allow port 22 and icmp traffic from the bastion
resource "openstack_networking_secgroup_rule_v2" "internal_ssh_access" {
  for_each          = { for idx, id in var.bastion_group_ids : idx => id }
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_group_id   = each.value
  security_group_id = openstack_networking_secgroup_v2.transport_load_balancer.id
}

resource "openstack_networking_secgroup_rule_v2" "bastion_icmp_access_v4" {
  for_each          = { for idx, id in var.bastion_group_ids : idx => id }
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_group_id   = each.value
  security_group_id = openstack_networking_secgroup_v2.transport_load_balancer.id
}

resource "openstack_networking_secgroup_rule_v2" "bastion_icmp_access_v6" {
  for_each          = { for idx, id in var.bastion_group_ids : idx => id }
  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "ipv6-icmp"
  remote_group_id   = each.value
  security_group_id = openstack_networking_secgroup_v2.transport_load_balancer.id
}

//Allow externally accessible ports
resource "openstack_networking_secgroup_rule_v2" "external_port_access" {
  for_each          = { for idx, port in var.external_ports: port => port }
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = each.value
  port_range_max    = each.value
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.transport_load_balancer.id
}

//Allow ports accessible only by clients
resource "openstack_networking_secgroup_rule_v2" "restricted_port_access" {
  for_each          = { for idx, restricted_port in local.restricted_ports: "group-idx-${idx}-port-${restricted_port.port}" => restricted_port }
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = each.value.port
  port_range_max    = each.value.port
  remote_group_id   = each.value.group_id
  security_group_id = openstack_networking_secgroup_v2.transport_load_balancer.id
}

//Allow port 9100 and icmp traffic from metrics server
resource "openstack_networking_secgroup_rule_v2" "metrics_server_node_exporter_access" {
  for_each          = { for idx, id in var.metrics_server_group_ids : idx => id }
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 9100
  port_range_max    = 9100
  remote_group_id   = each.value
  security_group_id = openstack_networking_secgroup_v2.transport_load_balancer.id
}

resource "openstack_networking_secgroup_rule_v2" "metrics_server_icmp_access_v4" {
  for_each          = { for idx, id in var.metrics_server_group_ids : idx => id }
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_group_id   = each.value
  security_group_id = openstack_networking_secgroup_v2.transport_load_balancer.id
}

resource "openstack_networking_secgroup_rule_v2" "metrics_server_icmp_access_v6" {
  for_each          = { for idx, id in var.metrics_server_group_ids : idx => id }
  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "ipv6-icmp"
  remote_group_id   = each.value
  security_group_id = openstack_networking_secgroup_v2.transport_load_balancer.id
}
