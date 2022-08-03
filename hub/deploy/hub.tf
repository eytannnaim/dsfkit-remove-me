# resource "aws_instance" "sonar_hub_instance" {
#   ami           = var.hub_amis_id[var.aws_region]
#   instance_type = var.hub_instance_type
#   key_name      = aws_key_pair.deployer.key_name
#   subnet_id = aws_subnet.public_subnet.id
#   tags = {
#     Name = "sonar-hub"
#   }
# }

resource "aws_eip" "sonar_hub_eip" {
  instance = aws_instance.sonar_hub_instance.id
  vpc      = true
}

resource "aws_key_pair" "deployer" {
  key_name   = "hub-key-pair"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCuEr/yHjzIXunGOPrLkLFjZ6Cns/8nOoGQApMAJp1sk6ZUq85TmTeaMM38nI037azJoytp6M4S3qRMZuw6VJlGmIY+23Mg7vkJlVBK0bc0CYZuiRm4g3XiNUxihyxDFSdbaDctuq25U8uRj04aG/pwAVWOG+ZN0b2bUqMDDtZKx19pjCY7TY/BRCwV88MTekFeqThfJiIS9HFikbjF85pjTTSPq/cWVjeb38PDmCxpfEZMRPjJxcay6MD8JcIH0yprnG11Kw5UFenQGP4VCrvO3zA+IpH3YPIqNpbXIND8cMT/90iFTiMuUULZ7AJAZ62sg4+iZmPniK0wZQZasXTttaV/GNj/nlo0PIkl+D1g5YocsICpsImG5s7WPruz02ICcWjSOSFpye/Uvj7E3XpHnj/gXGCM7Y69A/3x0GxqBvPsM3G62odnlZMHnfVk+3f1e6UjGV/k6EU3YvuQZyjif0xxQNOaYMorApIhmlgXnKFQOCDxHHHh3xFiYNX2iHM= gabi.beyo@MBP-175553.local"
}










# resource "aws_eip" "dsf_hub_eip" {
#   instance = aws_instance.dsf_hub_instance.id
#   vpc = true
# }

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
  # vpc_security_group_ids      = [aws_security_group.public.id]
  iam_instance_profile        = data.aws_iam_role.s3_full_read_access_profile.id
  tags = {
    Name = var.hub_machine_name
  }
}

# Remove this
data "aws_iam_role" "s3_full_read_access_profile" {
  name = "s3-full-read-access"
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
