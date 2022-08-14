##############################
# Generating ssh key pair
##############################

resource "aws_key_pair" "hub_ssh_keypair" {
  key_name      = "dsf_hub_ssh_keypair_${var.name}"
  public_key    =  data.local_file.dsf_hub_ssh_key.content
}

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

#################################
# Generating ssh federation keys
#################################
resource "null_resource" "dsf_hub_ssh_federation_key_pair_creator" {
  provisioner "local-exec" {
    command     = "rm -f dsf_hub_federation_ssh_key{,.pub} && ssh-keygen -b 4096 -t rsa -m PEM -f 'dsf_hub_federation_ssh_key' -P '' -q && chmod 400 dsf_hub_federation_ssh_key"
    interpreter = ["/bin/bash", "-c"]
  }
}

data "local_file" "dsf_hub_public_ssh_federation_key" {
  filename      = "dsf_hub_federation_ssh_key.pub"
  depends_on    = [null_resource.dsf_hub_ssh_federation_key_pair_creator]
}

data "local_sensitive_file" "dsf_hub_private_ssh_federation_key" {
  filename      = "dsf_hub_federation_ssh_key"
  depends_on    = [null_resource.dsf_hub_ssh_federation_key_pair_creator]
}

resource "aws_secretsmanager_secret" "dsf_hub_federation_public_key" {
  name          = "dsf_hub_federation_public_key_${var.name}"
  description   = "Imperva DSF Hub sonarw public ssh key - used for remote gw federation"
}

resource "aws_secretsmanager_secret_version" "dsf_hub_federation_public_key_ver" {
  secret_id     = aws_secretsmanager_secret.dsf_hub_federation_public_key.id
  secret_string = data.local_file.dsf_hub_public_ssh_federation_key.content
}

resource "aws_secretsmanager_secret" "dsf_hub_federation_private_key" {
  name          = "dsf_hub_federation_private_key_${var.name}"
  description   = "Imperva DSF Hub sonarw private ssh key - used for remote gw federation"
}

resource "aws_secretsmanager_secret_version" "dsf_hub_federation_private_key_ver" {
  secret_id     = aws_secretsmanager_secret.dsf_hub_federation_private_key.id
  secret_string = data.local_sensitive_file.dsf_hub_private_ssh_federation_key.content
}

data "template_file" "hub_cloudinit" {
  template = file("${path.module}/hub_cloudinit.tpl")
  vars = {
    admin_password      = var.admin_password
    secadmin_password   = var.admin_password
    sonarg_pasword      = var.admin_password
    sonargd_pasword     = var.admin_password
    dsf_hub_sonarw_private_ssh_key_name="dsf_hub_federation_private_key_${var.name}"
    dsf_hub_sonarw_public_ssh_key_name="dsf_hub_federation_public_key_${var.name}"
  }
  depends_on = [aws_secretsmanager_secret_version.dsf_hub_federation_public_key_ver, aws_secretsmanager_secret_version.dsf_hub_federation_private_key_ver]
}

resource "aws_iam_instance_profile" "dsf_hub_instance_iam_profile" {
  name = "dsf_hub_instance_iam_profile_${var.name}"
  role = "${aws_iam_role.dsf_hub_role.name}"
}

resource "aws_iam_role" "dsf_hub_role" {
  name = "imperva_dsf_hub_role"
  managed_policy_arns = null
  inline_policy {
    name = "imperva_dsf_hub_secret_access"
    policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
          {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "secretsmanager:GetSecretValue",
            "Resource": "${aws_secretsmanager_secret.dsf_hub_federation_public_key.arn}"
          }
        ]
      }
    )
  }
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

module "hub_instance" {
  source                = "../../modules/sonar_base_instance"
  name                  = join("-", [var.name, "hub"])
  subnet_id             = var.subnet_id
  ec2_user_data         = data.template_file.hub_cloudinit.rendered
  key_pair              = aws_key_pair.hub_ssh_keypair.key_name
  ec2_instance_type     = var.instance_type
  ebs_state_disk_size   = var.disk_size
  sg_ingress_cidr       = var.sg_ingress_cidr
  iam_instance_profile_id = aws_iam_instance_profile.dsf_hub_instance_iam_profile.id
}