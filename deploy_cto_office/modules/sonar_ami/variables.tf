variable "region" {
  type = string
}

variable "s3_bucket" {
  type = string
  sensitive = true
  description = "s3 bucket containing the installation tarball"
}

variable "environment" { 
  type = string
  description = "name of the deployment: dev, stage, prod, etc"
}

variable "dsf_install_tarball_path" {
  type = string
  description = "installation tarball path"
}

variable "instance_type" {
  type = string
  default = "t2.2xlarge"
  description = "Ec2 instance type"
}

variable "root_volume_size" {
  default = 60
}

variable "key_pair" {
  type = string
  description = "key pair for instance"
}

variable "subnet_id" {
  type = string
}

variable "template_file_path" {
  type = string
  description = "path to template file"
  default = "./cloudinit.tpl"
}

