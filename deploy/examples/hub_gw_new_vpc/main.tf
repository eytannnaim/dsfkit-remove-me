provider "aws" {
  region     = local.region
  #default_tags {
  #  tags = {
  #    env         = "development"
  #    product     = "imperva-dsf-hub"
  #    managed-by  = "terraform"
  #    created-at = formatdate("YYYY-MM-DD", timestamp())
  #  }
  #}
}

locals {
  region = "us-east-1"
  deployment-name = "imperva-dsf"
  admin_password = "Imp3rva12#"
  salt = substr(module.vpc.vpc_id, -8, -1)
#  sg_ingress_cidr = ["80.179.69.240/28"]
}

data "http" "workstartion_public_ip" {
  url = "https://ifconfig.me"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = local.deployment-name
  cidr = "10.0.0.0/16"

  azs             = ["${local.region}a", "${local.region}b", "${local.region}c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = false
  single_nat_gateway = true
}

module "hub" {
  source            = "../../modules/hub"
  name              = join("-", [local.deployment-name, local.salt])
  subnet_id         = module.vpc.public_subnets[0]
  admin_password    = local.admin_password
  sg_ingress_cidr   = [join("/", [data.http.workstartion_public_ip.body, "32"])]
}

module "agentless_gw" {
  count             = 1
  source            = "../../modules/gw"
  name              = join("-", [local.deployment-name, local.salt])
  admin_password    = local.admin_password
  subnet_id         = module.vpc.public_subnets[0]
  hub_ip            = module.hub.public_eip
  key_pair          = module.hub.hub_key_pair
  federation_public_key = module.hub.federation_public_key
  sg_ingress_cidr   = concat(["${data.http.workstartion_public_ip.body}/32"], ["${module.hub.public_eip}/32"])
}
