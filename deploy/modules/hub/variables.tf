variable "region" {
  type = string
}

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
  default = "imperva-dsf-hub"
  description = "Deployment name"
  validation {
    condition = length(var.name) > 3
    error_message = "Deployment name must be at least 3 characters"
  }
}

variable "subnet_id" {
  type = string
  description = "Subnet id for the DSF hub instance"
  validation {
    condition     = length(var.subnet_id) >= 15 && substr(var.subnet_id, 0, 7) == "subnet-"
    error_message = "Subnet id is invalid. Must be subnet-********."
  }
}

variable "instance_type" {
  type = string
  default = "t2.2xlarge"
  description = "Ec2 instance type for the DSF hub"
}

variable "disk_size" {
  default = 510
  validation {
    condition     = var.disk_size >= 500
    error_message = "DSF hub instance disk size must be at least 500GB"
  }
}

variable sg_ingress_cidr {
  type = list
  description = "List of allowed ingress cidr patterns for the DSF hub instance"
}

