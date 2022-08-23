variable "region" { default = "us-east-2" }

variable "name" {
  type = string
  default = "imperva-dsf-hub"
  description = "Instance name"
  validation {
    condition = length(var.name) > 3
    error_message = "Instnace name must be at least 3 characters."
  }
}

variable "subnet_id" {
  type = string
  description = "Subnet id for the DSF hub ec2 instance"
  validation {
    condition     = length(var.subnet_id) >= 15 && substr(var.subnet_id, 0, 7) == "subnet-"
    error_message = "Subnet id is invalid. Must be subnet-********."
  }
}

variable "key_pair" {
  type = string
  description = "key pair for DSF hub ec2 instance"
}

variable "s3_bucket" {
  type = string
  sensitive = true
  description = "s3 bucket containing the installation tarball"
}

variable "ec2_instance_type" {
  type = string
  default = "t2.2xlarge"
  description = "Ec2 instance type for the DSF hub"
}

variable "ebs_disk_size" {
  default = 510
  validation {
    condition     = var.ebs_disk_size >= 500
    error_message = "DSF hub instance disk size must be at least 500GB."
  }
}

variable "dsf_version" {
  type = string
  description = "dsf version folder name"
}

variable "dsf_install_tarball_path" {
  type = string
  description = "installation tarball path"
}

variable security_group_ingress_cidrs {
  type = list
  description = "List of allowed ingress cidr patterns for the DSF hub instance"
}

variable "federation_public_key_name" {
  type = string
  description = "DSF hub federation public key name"
}

variable "federation_private_key_name" {
  type = string
  description = "DSF hub federation public key name"
}

variable dsf_iam_profile_name {
  type = string
  default = null
  description = "DSF base ec2 IAM instance profile name"
}

variable "admin_password" {
  type = string
  sensitive = true
  description = "Admin password"
  validation {
    condition = length(var.admin_password) > 8
    error_message = "Admin password must be at least 8 characters."
  }
}

variable "secadmin_password" {
  type = string
  sensitive = true
  description = "Admin password"
  validation {
    condition = length(var.secadmin_password) > 8
    error_message = "Admin password must be at least 8 characters."
  }
}

variable "sonarg_pasword" {
  type = string
  sensitive = true
  description = "Admin password"
  validation {
    condition = length(var.sonarg_pasword) > 8
    error_message = "Admin password must be at least 8 characters."
  }
}

variable "sonargd_pasword" {
  type = string
  sensitive = true
  description = "Admin password"
  validation {
    condition = length(var.sonargd_pasword) > 8
    error_message = "Admin password must be at least 8 characters."
  }
}

######################## Additional (optional) parameters ########################
# Use this param to specify any additional parameters for the initial setup, example syntax below
# { default = "--jsonar-logdir=\"/path/to/log/dir\" --smtp-ssl --ignore-system-warnings" }
# https://sonargdocs.jsonar.com/4.5/en/sonar-setup.html#noninteractive-setup
variable "additional_parameters" { default = "" }