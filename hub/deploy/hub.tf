resource "aws_eip" "dsf_hub_eip" {
  instance = aws_instance.dsf_hub_instance.id
  vpc      = true
}

resource "random_id" "id" {
  byte_length = 8
}

resource "aws_key_pair" "dsf_hub_ssh_keypair" {
  key_name   = "dsf_hub_ssh_keypair_${random_id.id.hex}"
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

data "local_file" "dsf_hub_private_ssh_federation_key" {
  filename = "dsf_hub_federation_ssh_key"
  depends_on = [null_resource.dsf_hub_ssh_federation_key_pair_creator]
}

resource "aws_secretsmanager_secret" "dsf_hub_federation_public_key" {
  name = "dsf_hub_federation_public_key_${random_id.id.hex}"
  description = "Imperva DSF Hub sonarw public ssh key - used for remote gw federation"
}

resource "aws_secretsmanager_secret_version" "dsf_hub_federation_public_key_ver" {
  secret_id     = aws_secretsmanager_secret.dsf_hub_federation_public_key.id
  secret_string = data.local_file.dsf_hub_public_ssh_federation_key.content
}

resource "aws_secretsmanager_secret" "dsf_hub_federation_private_key" {
  name = "dsf_hub_federation_private_key_${random_id.id.hex}"
  description = "Imperva DSF Hub sonarw private ssh key - used for remote gw federation"
}

resource "aws_secretsmanager_secret_version" "dsf_hub_federation_private_key_ver" {
  secret_id     = aws_secretsmanager_secret.dsf_hub_federation_private_key.id
  secret_string = data.local_file.dsf_hub_private_ssh_federation_key.content
}

data "template_cloudinit_config" "dsf_hub_instance_config" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/x-shellscript"
    filename     = "dsf-init.sh"
    content      = <<-END
        
    END
  }
}

data "template_file" "hub_cloudinit" {
  template = file("${path.module}/hub_cloudinit.tpl")
  vars = {
    admin_password=var.user_password
    secadmin_password=var.user_password
    sonarg_pasword=var.user_password
    sonargd_pasword=var.user_password
    dsf_hub_sonarw_private_ssh_key_name="dsf_hub_federation_private_key_${random_id.id.hex}"
    dsf_hub_sonarw_public_ssh_key_name="dsf_hub_federation_public_key_${random_id.id.hex}"
  }
}

resource "aws_instance" "dsf_hub_instance" {
  ami           = var.hub_amis_id[var.aws_region]
  instance_type = var.dsf_hub_instance_type
  key_name      = aws_key_pair.dsf_hub_ssh_keypair.key_name
  subnet_id = aws_subnet.dsf_public_subnet.id
  # associate_public_ip_address = var.hub_public_ip
  user_data                   = data.template_file.hub_cloudinit.rendered
  iam_instance_profile = aws_iam_instance_profile.dsf_hub_instance_iam_profile.id
  # vpc_security_group_ids      = [aws_security_group.public.id]
  tags = {
    Name = "imperva-dsf-hub"
  }
  disable_api_termination = true
  depends_on = [aws_secretsmanager_secret_version.dsf_hub_federation_public_key_ver, aws_secretsmanager_secret_version.dsf_hub_federation_private_key_ver]
}

resource "aws_iam_instance_profile" "dsf_hub_instance_iam_profile" {
  name = "hub_dsf_hub_instance_iam_profile_${random_id.id.hex}"
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
  id = aws_subnet.dsf_public_subnet.id
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdb"
  volume_id   = aws_ebs_volume.ebs_vol.id
  instance_id = aws_instance.dsf_hub_instance.id
  stop_instance_before_detaching = true
}

resource "aws_ebs_volume" "ebs_vol" {
  size              = var.dsf_hub_disk_size
  type              = var.dsf_hub_disk_type
  availability_zone = data.aws_subnet.selected_subnet.availability_zone
  tags = {
    Name = "imperva-dsf-hub-volume"
  }
}
