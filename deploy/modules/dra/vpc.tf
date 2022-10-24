provider "aws" {
  region = var.region
}

locals {
  networks = [for index in range (6):cidrsubnet(var.vpc_cidr,8,index)]
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = var.vpc_cidr
  azs             = [ "${var.region}a", "${var.region}b"]
  private_subnets = [local.networks[0],local.networks[1]]
  public_subnets  = [local.networks[2], local.networks[3]]
  database_subnets = [local.networks[4],local.networks[5]]

  enable_ipv6 = false

  enable_nat_gateway = true
  single_nat_gateway = true

  create_database_subnet_group       = true
  create_database_subnet_route_table = true

  tags = {
    Owner       = "terraform"
  }

  vpc_tags = {
    Name = module.vpc.name
  }
}
