resource "aws_eip" "sonar_hub_eip" {
  instance = aws_instance.sonar_hub_instance.id
  vpc      = true
}

resource "aws_key_pair" "deployer" {
  key_name   = "hub-key-pair"
  public_key =  data.local_file.hub_key.content
}

resource "null_resource" "example1" {
  provisioner "local-exec" {
    command = "[ -f 'hub_key' ] || ssh-keygen -t rsa -f 'hub_key' -P ''"
    interpreter = ["/bin/bash", "-c"]
  }
}

data "local_file" "hub_key" {
  filename = "hub_key.pub"
  depends_on = [null_resource.example1]
}

data "template_cloudinit_config" "sonar_config" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/x-shellscript"
    filename     = "dsf-init.sh"
    content      = <<-END
        #!/bin/bash
        cd /root
        yum update -y
        /opt/sonar-dsf/jsonar/apps/*/bin/sonarg-setup --no-interactive --accept-eula --jsonar-uid-display-name "DSF-Hub" --jsonar-uid $(uuidgen) --not-remote-machine --product sonar-platform --newadmin-pass=my_password --secadmin-pass=my_password --sonarg-pass=my_password --sonargd-pass=my_password
    END
  }
}

resource "aws_instance" "sonar_hub_instance" {

  ami           = var.hub_amis_id[var.aws_region]
  instance_type = var.hub_instance_type
  key_name      = aws_key_pair.deployer.key_name
  subnet_id = aws_subnet.public_subnet.id
  # associate_public_ip_address = var.hub_public_ip
  user_data                   = data.template_cloudinit_config.sonar_config.rendered
  iam_instance_profile = data.aws_iam_role.s3_full_read_access_profile.id
  # vpc_security_group_ids      = [aws_security_group.public.id]
  tags = {
    Name = var.hub_machine_name
  }
}


data "aws_iam_role" "s3_full_read_access_profile" {
  name = "s3-full-read-access"
}

# resource "aws_instance" "sonar_hub_instance" {
#   ami           = var.hub_amis_id[var.aws_region]
#   instance_type = var.hub_instance_type
#   key_name      = aws_key_pair.deployer.key_name
#   subnet_id = aws_subnet.public_subnet.id
#   tags = {
#     Name = "sonar-hub"
#   }
# }

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
#  id = aws_subnet.public_subnet.id
#}
#
#resource "aws_volume_attachment" "ebs_att" {
#  device_name = "/dev/sdb"
#  volume_id   = aws_ebs_volume.ebs_vol.id
#  instance_id = aws_instance.dsf_hub_instance.id
#}
#
#resource "aws_ebs_volume" "ebs_vol" {
#  size              = var.hub_disk_size
#  type              = var.hub_disk_type
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
