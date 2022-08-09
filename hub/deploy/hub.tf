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

resource "null_resource" "federate_exec" {
  provisioner "local-exec" {
#    command = data.template_file.federate_script.rendered
    command = "./federate.sh $HUB_IP $GW_IP"
    interpreter = ["/bin/bash", "-c"]
    environment = {
      HUB_IP = aws_eip.dsf_hub_eip.public_ip
      GW_IP = aws_eip.dsf_gw_eip.public_ip
    }
  }
  depends_on = [aws_instance.dsf_hub_instance, aws_instance.dsf_hub_gw_instance]
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
    #admin_password=jsondecode(data.aws_secretsmanager_secret_version.sonar-secrets.secret_string)["admin_password"]
    #secadmin_password=jsondecode(data.aws_secretsmanager_secret_version.sonar-secrets.secret_string)["secadmin_password"]
    #sonarg_pasword=jsondecode(data.aws_secretsmanager_secret_version.sonar-secrets.secret_string)["sonarg_pasword"]
    #sonargd_pasword=jsondecode(data.aws_secretsmanager_secret_version.sonar-secrets.secret_string)["sonargd_pasword"]
    admin_password="Imp3rva12#"
    secadmin_password="Imp3rva12#"
    sonarg_pasword="Imp3rva12#"
    sonargd_pasword="Imp3rva12#"
    dsf_hub_sonarw_private_ssh_key_name="dsf_hub_federation_private_key_${random_id.id.hex}"
    dsf_hub_sonarw_public_ssh_key_name="dsf_hub_federation_public_key_${random_id.id.hex}"
  }
}

data "template_file" "federate_script" {
  template = file("${path.module}/federate.tpl")
  vars = {
    dsf_hub_ip=aws_eip.dsf_hub_eip.public_ip
    dsf_gw_ip=aws_eip.dsf_gw_eip.public_ip
  }
}

data "template_file" "gw_cloudinit" {
  template = file("${path.module}/gw_cloudinit.tpl")
  vars = {
    #admin_password=jsondecode(data.aws_secretsmanager_secret_version.sonar-secrets.secret_string)["admin_password"]
    #secadmin_password=jsondecode(data.aws_secretsmanager_secret_version.sonar-secrets.secret_string)["secadmin_password"]
    #sonarg_pasword=jsondecode(data.aws_secretsmanager_secret_version.sonar-secrets.secret_string)["sonarg_pasword"]
    #sonargd_pasword=jsondecode(data.aws_secretsmanager_secret_version.sonar-secrets.secret_string)["sonargd_pasword"]
    admin_password="Imp3rva12#"
    secadmin_password="Imp3rva12#"
    sonarg_pasword="Imp3rva12#"
    sonargd_pasword="Imp3rva12#"
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

# consider removing this
#resource "aws_kms_key" "imperva_hub_kms" {
#  description             = "Imperva DSF Hub kms key"
##  deletion_window_in_days = 10
#}
#
#data "aws_kms_ciphertext" "encrypted_password" {
#  key_id     = aws_kms_key.imperva_hub_kms.key_id
#  plaintext  = random_password.password.result
#  depends_on = [aws_kms_key.imperva_hub_kms]
#}

## Attach an additional storage device to DSF hub files
#data "aws_subnet" "selected_subnet" {
#  id = aws_subnet.dsf_public_subnet.id
#}
#
#resource "aws_volume_attachment" "ebs_att" {
#  device_name = "/dev/sdb"
#  volume_id   = aws_ebs_volume.ebs_vol.id
#  instance_id = aws_instance.dsf_hub_instance.id
#}
#
#resource "aws_ebs_volume" "ebs_vol" {
#  size              = var.dsf_hub_disk_size
#  type              = var.dsf_hub_disk_type
#  availability_zone = data.aws_subnet.selected_subnet.availability_zone
#}

# gaps:
# how to copy the installation file
# add time wait condition that waits until GUI is visible (6 minutes to gui to became active)
# remove you role
# solve pem issue
# solve the package download issue
# propate random password to hub
# Add additional logical volume for DSF hub files - this is an instance depended solution and therefore should be handled in the future
# make userdata run always to fix overcome issues that might be affected by a reboot or a disk change or a instance change - https://aws.amazon.com/premiumsupport/knowledge-center/execute-user-data-ec2/
# add condition variable and wait until installation complete
# add some feedback for the hub installation
