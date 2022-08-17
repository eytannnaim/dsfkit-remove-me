provider "aws" {
  region = local.main_region
}

provider "aws" {
  region = local.sec_region
  alias  = "europe"
}

locals {
  main_region = "us-east-1"
  sec_region = "eu-west-2"
  deployment-name = "imperva-dsf"
  admin_password = "Imp3rva12#"
  salt = substr(module.vpc.vpc_id, -8, -1)
}

data "http" "workstartion_public_ip" {
  url = "https://ifconfig.me"
}

##############################
# Generating ssh key pair
##############################

module "key_pair" {
  source = "terraform-aws-modules/key-pair/aws"
  key_name           = "dsf_hub_ssh_key"
  create_private_key = true
}

resource "local_sensitive_file" "dsf_hub_ssh_key_file" {
  content = module.key_pair.private_key_pem
  file_permission = 400
  filename = "dsf_hub_ssh_key"
}

resource "aws_key_pair" "hub_ssh_keypair_europe" {
  provider      = aws.europe
  key_name      = module.key_pair.key_pair_name
  public_key    = module.key_pair.public_key_openssh
}

##############################
# Generating network
##############################

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = local.deployment-name
  cidr = "10.0.0.0/16"

  azs             = ["${local.main_region}a", "${local.main_region}b", "${local.main_region}c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = false
  single_nat_gateway = true
}

module "vpc2" {
  source = "terraform-aws-modules/vpc/aws"

  providers         = {
    aws = aws.europe
  }

  name = local.deployment-name
  cidr = "10.0.0.0/16"

  azs             = ["${local.sec_region}a", "${local.sec_region}b", "${local.sec_region}c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = false
  single_nat_gateway = true
}

##############################
# Generating deployment
##############################

module "hub" {
  source            = "../../modules/hub"
  name              = join("-", [local.deployment-name, local.salt])
  subnet_id         = module.vpc.public_subnets[0]
  key_pair          = module.key_pair.key_pair_name
  admin_password    = local.admin_password
  sg_ingress_cidr   = [join("/", [data.http.workstartion_public_ip.body, "32"])]
}

module "agentless_gw" {
  count             = 1
  providers         = {
    aws = aws.europe
  }
  source            = "../../modules/gw"
  name              = join("-", [local.deployment-name, local.salt])
  admin_password    = local.admin_password
  subnet_id         = module.vpc2.public_subnets[0]
  hub_ip            = module.hub.public_address
  key_pair          = module.key_pair.key_pair_name
  federation_public_key = module.hub.federation_public_key
  sg_ingress_cidr   = concat(["${data.http.workstartion_public_ip.body}/32"], ["${module.hub.public_address}/32"])
}
