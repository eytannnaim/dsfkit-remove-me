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
}

data "http" "workstartion_public_ip" {
  url = "https://ifconfig.me"
}

##############################
# Generating ssh key pair
##############################

resource "null_resource" "dsf_hub_ssh_key_pair_creator" {
  provisioner "local-exec" {
    command     = "[ -f 'dsf_hub_ssh_key' ] || ssh-keygen -t rsa -f 'dsf_hub_ssh_key' -P '' -q && chmod 400 dsf_hub_ssh_key"
    interpreter = ["/bin/bash", "-c"]
  }
}

data "local_file" "dsf_hub_ssh_key" {
  filename      = "dsf_hub_ssh_key.pub"
  depends_on    = [null_resource.dsf_hub_ssh_key_pair_creator]
}

resource "aws_key_pair" "hub_ssh_keypair" {
  key_name      = "dsf_hub_ssh_keypair"
  public_key    =  data.local_file.dsf_hub_ssh_key.content
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
  key_pair          = aws_key_pair.hub_ssh_keypair.key_name
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
  key_pair          = aws_key_pair.hub_ssh_keypair.key_name
  federation_public_key = module.hub.federation_public_key
  sg_ingress_cidr   = concat(["${data.http.workstartion_public_ip.body}/32"], ["${module.hub.public_eip}/32"])
}
