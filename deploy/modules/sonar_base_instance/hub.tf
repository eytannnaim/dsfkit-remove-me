locals {
  ebs_state_disk_type = "gp3"
}

resource "aws_eip" "dsf_hub_eip" {
  instance = aws_instance.dsf_hub_instance.id
  vpc      = true
}

resource "aws_key_pair" "dsf_hub_ssh_keypair" {
  key_name   = "dsf_hub_ssh_keypair_${var.name}"
  public_key =  data.local_file.dsf_hub_ssh_key.content
}

resource "null_resource" "dsf_hub_ssh_key_pair_creator" {
  provisioner "local-exec" {
    command = "[ -f 'dsf_hub_ssh_key' ] || ssh-keygen -t rsa -f 'dsf_hub_ssh_key' -P '' -q && chmod 400 dsf_hub_ssh_key"
    interpreter = ["/bin/bash", "-c"]
  }
}

resource "null_resource" "dsf_hub_ssh_federation_key_pair_creator" {
  provisioner "local-exec" {
    command = "rm -f dsf_hub_federation_ssh_key{,.pub} && ssh-keygen -b 4096 -t rsa -m PEM -f 'dsf_hub_federation_ssh_key' -P '' -q && chmod 400 dsf_hub_federation_ssh_key"
    interpreter = ["/bin/bash", "-c"]
  }
}

data "local_file" "dsf_hub_ssh_key" {
  filename = "dsf_hub_ssh_key.pub"
  depends_on = [null_resource.dsf_hub_ssh_key_pair_creator]
}

data "local_file" "dsf_hub_public_ssh_federation_key" {
  filename = "dsf_hub_federation_ssh_key.pub"
  depends_on = [null_resource.dsf_hub_ssh_federation_key_pair_creator]
}

data "local_sensitive_file" "dsf_hub_private_ssh_federation_key" {
  filename = "dsf_hub_federation_ssh_key"
  depends_on = [null_resource.dsf_hub_ssh_federation_key_pair_creator]
}

resource "aws_secretsmanager_secret" "dsf_hub_federation_public_key" {
  name = "dsf_hub_federation_public_key_${var.name}"
  description = "Imperva DSF Hub sonarw public ssh key - used for remote gw federation"
}

resource "aws_secretsmanager_secret_version" "dsf_hub_federation_public_key_ver" {
  secret_id     = aws_secretsmanager_secret.dsf_hub_federation_public_key.id
  secret_string = data.local_file.dsf_hub_public_ssh_federation_key.content
}

resource "aws_secretsmanager_secret" "dsf_hub_federation_private_key" {
  name = "dsf_hub_federation_private_key_${var.name}"
  description = "Imperva DSF Hub sonarw private ssh key - used for remote gw federation"
}

resource "aws_secretsmanager_secret_version" "dsf_hub_federation_private_key_ver" {
  secret_id     = aws_secretsmanager_secret.dsf_hub_federation_private_key.id
  secret_string = data.local_sensitive_file.dsf_hub_private_ssh_federation_key.content
}

resource "aws_instance" "dsf_hub_instance" {
  ami           = var.hub_amis_id[var.region]
  instance_type = var.ec2_instance_type
  key_name      = aws_key_pair.dsf_hub_ssh_keypair.key_name
  subnet_id = var.subnet_id
  # associate_public_ip_address = var.hub_public_ip
  user_data                   = var.ec2_user_data
  iam_instance_profile = aws_iam_instance_profile.dsf_hub_instance_iam_profile.id
  # vpc_security_group_ids      = [aws_security_group.public.id]
  tags = {
    Name = join("-", [var.name, "hub" ])
  }
  disable_api_termination = true
  depends_on = [aws_secretsmanager_secret_version.dsf_hub_federation_public_key_ver, aws_secretsmanager_secret_version.dsf_hub_federation_private_key_ver]
}

resource "aws_iam_instance_profile" "dsf_hub_instance_iam_profile" {
  name = "hub_dsf_hub_instance_iam_profile_${var.name}"
  role = "${aws_iam_role.dsf_hub_role.name}"
}

resource "aws_iam_role" "dsf_hub_role" {
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

# Attach an additional storage device to DSF hub files
data "aws_subnet" "selected_subnet" {
  id = var.subnet_id
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdb"
  volume_id   = aws_ebs_volume.ebs_vol.id
  instance_id = aws_instance.dsf_hub_instance.id
  stop_instance_before_detaching = true
}

resource "aws_ebs_volume" "ebs_vol" {
  size              = var.ebs_state_disk_size
  type              = local.ebs_state_disk_type
  availability_zone = data.aws_subnet.selected_subnet.availability_zone
  tags = {
    Name = join("-", [var.name, "hub", "volume"])
  }
}
