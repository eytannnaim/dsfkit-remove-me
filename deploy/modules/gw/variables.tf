variable "admin_password" {
  type = string
  sensitive = true
  description = "Admin password"
  validation {
    condition = length(var.admin_password) > 8
    error_message = "Admin password must be at least 8 characters"
  }
}

variable "name" {
  type = string
  default = "imperva-dsf-agentless-gw"
  description = "Deployment name"
  validation {
    condition = length(var.name) > 3
    error_message = "Deployment name must be at least 3 characters"
  }
}

variable "subnet_id" {
  type = string
  description = "Subnet id for the DSF agentless gw ec2 instance"
  validation {
    condition     = length(var.subnet_id) >= 15 && substr(var.subnet_id, 0, 7) == "subnet-"
    error_message = "Subnet id is invalid. Must be subnet-********"
  }
}

variable "instance_type" {
  type = string
  default = "t2.2xlarge"
  description = "Ec2 instance type for the DSF agentless gw"
}

variable "disk_size" {
  default = 150
  validation {
    condition     = var.disk_size >= 150
    error_message = "DSF agentless gw disk size must be at least 150GB"
  }
}

variable sg_ingress_cidr {
  type = list
  description = "List of allowed ingress cidr patterns for the DSF agentless gw instance"
}

variable sg_ingress_hub {
  default = []
  type = list
  description = "Allowed ingress sg id for the DSF hub instance"
}

variable "key_pair" {
  type = string
  description = "key pair for DSF agentless gw ec2 instance. This key must be generated by by the hub module and present on the local disk"
}

variable "federation_public_key" {
  type = string
  description = "DSF hub federation public key"
}

variable "hub_ip" {
  type = string
  description = "DSF hub IP address"
  validation {
    condition = can(regex("^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", var.hub_ip))
    error_message = "Invalid IP address provided"
  }
}
