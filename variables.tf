variable "load_balancer_group_name" {
  description = "Name to give to the security group of load balancers"
  type = string
  default = ""
}

variable "external_ports" {
  description = "List of ports that are externall accessible to all"
  type = list(number)
  default = []
}

variable "restricted_ports" {
  description = "List of ports that are accessible to specific security groups"
  type = list(object({
    port = number
    group_ids = list(string)
  }))
  default = []
}

variable "bastion_group_ids" {
  description = "Id of bastion security groups"
  type = list(string)
  default = []
}

variable "metrics_server_group_ids" {
  description = "Id of metric servers security groups"
  type = list(string)
  default = []
}

variable "fluentd_security_group" {
  description = "Fluentd security group configuration"
  type        = object({
    id   = string
    port = number
  })
  default = {
    id   = ""
    port = 0
  }
}
