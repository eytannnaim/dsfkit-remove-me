provider "aws" {
  region = local.region
}

locals {
  region = "us-east-1"
  deployment-name = "imperva-dsf"
}

################################################################################
# VPC Module
################################################################################

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = local.deployment-name
  cidr = "10.0.0.0/16"

  azs             = ["${local.region}a", "${local.region}b", "${local.region}c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_ipv6 = true

  enable_nat_gateway = false
  single_nat_gateway = true

  #public_subnet_tags = {
  #  Name = "overridden-name-public"
  #}

  tags = {
    Owner       = local.deployment-name
    Environment = "dev"
  }

  vpc_tags = {
    Name = local.deployment-name
  }
}

module "hub" {
  source = "../../modules/hub"

  region = local.region
  
  name = local.deployment-name
  
  subnet_id = module.vpc.public_subnets[0]
  
  admin_password = "Imp3rva12#"
  
  #cidr = "10.0.0.0/16"
  #
  #azs             = ["${local.region}a", "${local.region}b", "${local.region}c"]
  #private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  #public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  #
  #enable_ipv6 = true
  #
  #enable_nat_gateway = false
  #single_nat_gateway = true
  #
  ##public_subnet_tags = {
  ##  Name = "overridden-name-public"
  ##}
  #
  #tags = {
  #  Owner       = local.deployment-name
  #  Environment = "dev"
  #}
  #
  #vpc_tags = {
  #  Name = local.deployment-name
  #}
}
