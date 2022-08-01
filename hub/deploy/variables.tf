variable "aws_region" {
  type = string
}

variable "sonar_version" {
  type = string
}

variable "hub_instance_type" {
  type = string
}

variable "hub_ami_id" {
  type = string
}

variable "hub_amis_id" {
  type = map(any)
  default = {
    eu-west-2 = "ami-013984d976f6d6894"
    eu-west-1 = "ami-065ec1e661d619058"
  }
}


variable "aws_access_key" {
  type = string

}

variable "aws_secret_key" {
  type = string
}


variable "hub_vpc_cidr" {
  type = string
}

variable "hub_public_subnet_cidr" {
  type = string
}

variable "hub_private_subnet_cidr" {
  type = string
}