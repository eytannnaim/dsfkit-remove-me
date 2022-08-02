terraform {
  required_version = ">= 0.13"
}

provider "aws" {
  profile = var.profile
  region  = var.region
}

##################################################### 
######### Upload certs into secrets manager #########
##################################################### 
variable "public_ssh_key_path" { default = "keys/id_rsa_sonar_dev.pub" }
variable "private_ssh_key_path" { default = "keys/id_rsa_sonar_dev" }

data "local_file" "private_key" {
    filename = var.private_ssh_key_path
}

data "local_file" "public_key" {
    filename = var.public_ssh_key_path
}

##################################################### 
####### Retrieve aws credentials from secrets #######
##################################################### 
data "aws_secretsmanager_secret" "sonar-secrets" {
  name = "sonar_secrets"
}

data "aws_secretsmanager_secret_version" "sonar-secrets" {
  secret_id = data.aws_secretsmanager_secret.sonar-secrets.id
}

data "aws_secretsmanager_secret" "aws-creds" {
  name = "s3_read_only"
}

data "aws_secretsmanager_secret_version" "aws-creds" {
  secret_id = data.aws_secretsmanager_secret.aws-creds.id
}

data "template_file" "sonarw_init" {
  template = file("${path.module}/sonarw_init.tpl")
  vars = {
    sonar_image_name=var.sonar_image_name
    sonar_version=var.sonar_version
    sonar_install_file=var.sonar_install_file
    public_key=data.local_file.public_key.content
    private_key=data.local_file.private_key.content
    aws_access_key_id=jsondecode(data.aws_secretsmanager_secret_version.aws-creds.secret_string)["aws_access_key_id"]
    aws_secret_access_key=jsondecode(data.aws_secretsmanager_secret_version.aws-creds.secret_string)["aws_secret_access_key"]
    admin_password=jsondecode(data.aws_secretsmanager_secret_version.sonar-secrets.secret_string)["admin_password"]
    secadmin_password=jsondecode(data.aws_secretsmanager_secret_version.sonar-secrets.secret_string)["secadmin_password"]
    sonarg_pasword=jsondecode(data.aws_secretsmanager_secret_version.sonar-secrets.secret_string)["sonarg_pasword"]
    sonargd_pasword=jsondecode(data.aws_secretsmanager_secret_version.sonar-secrets.secret_string)["sonargd_pasword"]
    additional_parameters=var.additional_parameters
  }
}

data "aws_ami" "SONAR_INSTANCE" {
  owners = ["aws-marketplace"]
  filter {
    name   = "name"
    values = ["ca036d10-2e28-4b60-ba48-61e66b8e29a8.0f79e08e-623c-448a-aaf8-01980c58858a.DC0001"]
  }
}

resource "aws_instance" "sonarw" {
  ami           = data.aws_ami.SONAR_INSTANCE.id
  instance_type = "c5.4xlarge"
  tags = {
    Name = var.sonar_image_name
  }
  key_name                    = var.key_pair
  subnet_id                   = var.subnet_id
  associate_public_ip_address = false
  user_data                   = data.template_file.sonarw_init.rendered
  disable_api_termination     = false
  ebs_optimized               = false
  monitoring                  = false
  credit_specification {
    cpu_credits = "standard"
  }
  vpc_security_group_ids = [aws_security_group.allow_sonar.id]
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdb"
  volume_id   = aws_ebs_volume.ebs_vol.id
  instance_id = aws_instance.sonarw.id
}

resource "aws_ebs_volume" "ebs_vol" {
  availability_zone = var.availability_zone
  size              = var.sonar_aws_ebs_volume_size
}

resource "aws_security_group" "allow_sonar" {
  name   = "Allow Sonar Access snr-wh1"
  vpc_id = var.vpc_id
  ingress {
    from_port   = 8080
    protocol    = "TCP"
    to_port     = 8443
    cidr_blocks = var.security_group_ingress
  }
  ingress {
    from_port   = 8443
    protocol    = "TCP"
    to_port     = 8443
    cidr_blocks = var.security_group_ingress
  }
  ingress {
    from_port   = 22
    protocol    = "TCP"
    to_port     = 22
    cidr_blocks = var.security_group_ingress
  }
  ingress {
    from_port   = 3030
    protocol    = "TCP"
    to_port     = 3030
    cidr_blocks = var.security_group_ingress
  }
  ingress {
    from_port   = 27117
    protocol    = "TCP"
    to_port     = 27117
    cidr_blocks = var.security_group_ingress
  }
  ingress {
    from_port   = 27133
    protocol    = "TCP"
    to_port     = 27133
    cidr_blocks = var.security_group_ingress
  }
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}