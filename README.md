# About

This is a terraform module that provisions security groups meant to be restrict network access to a transport load balancer server.

The following security group is created:
- **load_balancer**: Security group for the load balancer. It can make external requests and is externally accessible through ports defined in the module's input.

Additionally, you can pass a list of groups that will fulfill each of the following roles:
- **bastion**: Security groups that will have access to the load balancer on port **22** as well as **icmp** traffic.
- **metrics_server**: Security groups that will have access to the load balancer on ports **9090** and **9100** as well as icmp traffic.

# Usage

## Variables

The module takes the following variables as input:

- **load_balancer_group_name**: Name to give to the security group for the load balancer
- **bastion_group_ids**: List of ids of security groups that should have **bastion** access to the load balancer
- **metrics_server_group_ids**: List of ids of security groups that should have **metrics server** access to the load balancer.
- **external_ports**: List of ports (represented as numbers) that should be externally accessible by everyone
- **restricted_ports**: List of ports accessible only to certain security groups. Each entry in the list should have the following keys:
  - **port**: Port that is made accessible
  - **group_ids**: List of security group ids that should have access to the port

## Output

The module outputs the following variables as output:

- **load_balancer_group**: Security group for the load balancer that got created. It contains a resource of type **openstack_networking_secgroup_v2**