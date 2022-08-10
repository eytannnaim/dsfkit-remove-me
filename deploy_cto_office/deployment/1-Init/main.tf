terraform {
  required_version = ">= 0.12.8"
}

provider "aws" {
  region = var.region
}

resource "aws_secretsmanager_secret" "sonar_secrets" {
  name = "${var.environment}/sonar"
}

# /* Populate AWS secrets */
# resource "random_password" "admin_password" {
#   length = 13
#   special = true
#   override_special = "#"
# }

# /* Populate AWS secrets */
# resource "random_password" "secadmin_password" {
#   length = 13
#   special = true
#   override_special = "#"
# }

# /* Populate AWS secrets */
# resource "random_password" "sonarg_pasword" {
#   length = 13
#   special = true
#   override_special = "#"
# }

# /* Populate AWS secrets */
# resource "random_password" "sonargd_pasword" {
#   length = 13
#   special = true
#   override_special = "#"
# }

# locals {
#   sonar_obj  = {
#     admin_password = random_password.admin_password.result
#     secadmin_password = random_password.secadmin_password.result
#     sonarg_pasword = random_password.sonarg_pasword.result
#     sonargd_pasword = random_password.sonargd_pasword.result
#   }
# }

locals {
  uniqueName = uuid()
  sonar_obj  = {
    admin_password = "Imperva123#"
    secadmin_password = "Imperva123#"
    sonarg_pasword = "Imperva123#"
    sonargd_pasword = "Imperva123#"
  }
}

resource "aws_secretsmanager_secret_version" "ses" {
  secret_id     = aws_secretsmanager_secret.sonar_secrets.id
  secret_string = jsonencode(local.sonar_obj)
}

data "aws_instance" "sonar-snow-dev" {
  filter {
    name   = "tag:Name"
    values = ["sonar-snow-dev"]
  }
}

resource "aws_iam_policy" "sonar_role_policy" {
  name = "sonar_role_policy_${local.uniqueName}"
  description = "A policy to allow secret decryption"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetResourcePolicy",
                "secretsmanager:GetSecretValue",
                "secretsmanager:DescribeSecret",
                "secretsmanager:ListSecretVersionIds"
            ],
            "Resource": ["${data.aws_instance.sonar-snow-dev.arn}"]
        },
        {
            "Effect": "Allow",
            "Action": "secretsmanager:ListSecrets",
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_policy_attachment" "role_attach_sonar_role_policy" {
  name = "role_attach_sonar_role_policy_ ${local.uniqueName}"
  roles = [aws_iam_role.SonarRootRole.name]
  policy_arn = aws_iam_policy.sonar_role_policy.arn
}

resource "aws_iam_role" "SonarRootRole" {
  name = "SonarRootRole${local.uniqueName}"
  path = "/"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": "sts:AssumeRole",
            "Principal": {
              "Service":"ec2.amazonaws.com"
            }
        }
     ]
}
EOF
}

resource "aws_iam_instance_profile" "SonarRootInstanceProfile" {
  name = "SonarRootInstanceProfile_${local.uniqueName}"
  role = aws_iam_role.SonarRootRole.name
}