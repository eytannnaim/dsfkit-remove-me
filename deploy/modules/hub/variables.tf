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
  description = "Subnet id for the DSF hub instance"
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
