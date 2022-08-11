locals {
  ebs_state_disk_type = "gp3"
}

resource "aws_eip" "dsf_instance_eip" {
  instance = aws_instance.dsf_base_instance.id
  vpc      = true
}

resource "aws_instance" "dsf_base_instance" {
  ami                           = var.dsf_base_amis_id[var.region]
  instance_type                 = var.ec2_instance_type
  key_name                      = var.key_pair
  subnet_id                     = var.subnet_id
  user_data                     = var.ec2_user_data
  iam_instance_profile          = aws_iam_instance_profile.dsf_base_instance_iam_profile.id
  vpc_security_group_ids        = [aws_security_group.public.id]
  tags = {
    Name = var.name
  }
  disable_api_termination = true
}

resource "aws_iam_instance_profile" "dsf_base_instance_iam_profile" {
  name = "dsf_base_instance_iam_profile_${var.name}"
  role = "${aws_iam_role.dsf_base_role.name}"
}

resource "aws_iam_role" "dsf_base_role" {
  managed_policy_arns = ["arn:aws:iam::aws:policy/SecretsManagerReadWrite"]
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

# Attach an additional storage device to DSF base instance
data "aws_subnet" "selected_subnet" {
  id = var.subnet_id
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdb"
  volume_id   = aws_ebs_volume.ebs_vol.id
  instance_id = aws_instance.dsf_base_instance.id
  stop_instance_before_detaching = true
}

resource "aws_ebs_volume" "ebs_vol" {
  size              = var.ebs_state_disk_size
  type              = local.ebs_state_disk_type
  availability_zone = data.aws_subnet.selected_subnet.availability_zone
  tags = {
    Name = var.name
  }
}
