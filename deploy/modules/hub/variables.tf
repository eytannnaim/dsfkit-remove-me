variable "region" {
  type = string
}

variable "admin_password" {
  type = string
  sensitive = true
}

variable "name" {
  type = string
  default = "imperva-dsf-hub"
}

variable "subnet_id" {
  type = string
  description = "Subnet id for the ec2 instance"
}

variable "dsf_hub_instance_type" {
  type = string
  default = "t2.2xlarge"
  description = "Ec2 instance type for the hub"
}

variable "dsf_hub_disk_size" {
  default = 510
  validation {
    condition     = var.dsf_hub_disk_size >= 500
    error_message = "Disk size must be at least 500GB"
  }
}
