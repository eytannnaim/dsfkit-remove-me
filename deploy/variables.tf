variable "aws_region" {
  type = string
}

variable "aws_access_key" {
  type = string
}

variable "aws_secret_key" {
  type = string
}

variable "user_password" {
  type = string
  default = "Imp3rva12#"
}

variable "dsf_vpc_cidr" {
  type = string
}

variable "hub_dsf_public_subnet_cidr" {
  type = string
}

variable "hub_dsf_private_subnet_cidr" {
  type = string
}

variable "dsf_hub_instance_type" {
  type = string
}

data "http" "workstartion_public_ip" {
  url = "http://ifconfig.me"
}

variable "vpn_security_group_cidr" { default = ["80.179.69.240/28"] }

variable "dsf_hub_disk_size" {
  default = 510
  validation {
    condition     = var.dsf_hub_disk_size >= 500
    error_message = "Disk size must be at least 500GB"
  }
}

variable "dsf_hub_disk_type" {
  default = "gp3"
}


# resource "random_password" "password" {
#   length           = 16
#   special          = true
#   override_special = "!#$%&*()-_=+[]{}<>:?"
# }

# variable "hub_public_ip" {
#   default = true
# }

# variable "hub_key_pair" {
#   type = string
# }


# This list was created with the following command
# > for r in $(awsregions) ; do echo $r = $(aws --region $r ec2 describe-images  --filters Name=name,Values=RHEL-7.9_HVM-202205* | jq '.Images[0]."ImageId" '); done
variable "hub_amis_id" {
  type = map(any)
  default = {
    us-east-1 = "ami-064196ba51ee65773"
    eu-west-2 = "ami-03a6c38b3c0aa74f9"
  }
}

##########################################
#   RHEL-7 AMI list per region 
## This list was created with the following command
## > for r in $(awsregions) ; do echo $r = $(aws --region $r ec2 describe-images  --filters Name=name,Values=RHEL-7.9_HVM-202205* | jq '.Images[0]."ImageId" '); done
#variable "rhel79_amis_ids" {
#  type = map(any)
#  default = {
#    af-south-1 = "ami-064aeb2452a82205f"
#    ap-east-1 = "ami-0e377c3509b0a1490"
#    ap-northeast-1 = "ami-0073b6113281aa32e"
#    ap-northeast-2 = "ami-04adf7ab262061270"
#    ap-northeast-3 = "ami-0ea15419fc3544d6a"
#    ap-south-1 = "ami-01dd6bbea8d062bf3"
#    ap-southeast-1 = "ami-0ee6bfca4452064bc"
#    ap-southeast-2 = "ami-0bf7d72cc0b127581"
#    ca-central-1 = "ami-0f1c453d5ca1059f0"
#    eu-central-1 = "ami-0a62e33b5dcf31c85"
#    eu-north-1 = "ami-0a32f8cdd314cf493"
#    eu-south-1 = "ami-0f18d0a883583eaa9"
#    eu-west-1 = "ami-06211bde2f9c725e5"
#    eu-west-2 = "ami-0a8aebd46fb700315"
#    eu-west-3 = "ami-07185297899bb7755"
#    me-south-1 = "ami-02f76563b3f70c99d"
#    sa-east-1 = "ami-08acb85e5164523d7"
#    us-east-1 = "ami-004fac3d4533a2541"
#    us-east-2 = "ami-0bb2449c2217cb9b0"
#    us-west-1 = "ami-085733fd69e77a079"
#    us-west-2 = "ami-027da4fca766221c9"
#  }
#}