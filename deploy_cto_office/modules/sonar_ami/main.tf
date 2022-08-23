provider "aws" {
  region = var.region
}

data "template_file" "cloudinit" {
  template = file(var.template_file_path)
  vars = {
    s3_bucket                 = var.s3_bucket
    dsf_install_tarball_path  = var.dsf_install_tarball_path
  }
}

resource "aws_iam_instance_profile" "dsf_hub_instance_iam_profile" {
  name = "dsf_hub_instance_iam_profile_${var.region}_${var.environment}"
  role = "${aws_iam_role.dsf_hub_role.name}"
}

resource "aws_iam_role" "dsf_hub_role" {
  name = "imperva_dsf_hub_role-${var.region}_${var.environment}"
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonS3FullAccess"]
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

data "aws_ami" "rhel79_ami_id" {
    owners = ["aws-marketplace"]
    filter {
        name = "name"
        values = ["ca036d10-2e28-4b60-ba48-61e66b8e29a8.0f79e08e-623c-448a-aaf8-01980c58858a.DC0001"]
    }
}

resource "aws_instance" "dsf_base_instance" {
  ami                           = data.aws_ami.rhel79_ami_id.id
  instance_type                 = var.instance_type
  key_name                      = var.key_pair
  subnet_id                     = var.subnet_id
  user_data                     = data.template_file.cloudinit.rendered
  iam_instance_profile          = aws_iam_instance_profile.dsf_hub_instance_iam_profile.id
  root_block_device {
    volume_size                 = var.root_volume_size
  }
  tags = {
    Name = "dsf-base-ami-${var.region}-${var.environment}"
  }
  disable_api_termination = true
}
