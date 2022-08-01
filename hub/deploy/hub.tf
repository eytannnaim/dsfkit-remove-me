resource "aws_eip" "dsf_hub_eip" {
  instance = aws_instance.dsf_hub_instance.id
  vpc = true
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
        yum install unzip -y
        
        # Preperations for install
        DIR=/opt/sonar-dsf
        useradd sonargd
        useradd sonarg
        useradd sonarw
        groupadd sonar
        usermod -g sonar sonarw
        usermod -g sonar sonargd
        mkdir -p $DIR

        # Creating logical volume for DSF hub files - this is instance depended and therefore should be handled in the future
        #yum install lvm2 -y
        #pvcreate -ff /dev/nvme1n1 -y
        #vgcreate data /dev/nvme1n1 
        #lvcreate -n vol0 -l 100%FREE data -y
        #mkfs.xfs /dev/mapper/data-vol0
        #echo "$(blkid /dev/mapper/data-vol0 | cut -d ':' -f2 | awk '{print $1}') /opt xfs defaults 0 0" | sudo tee -a /etc/fstab
        #sudo mount -a
        
        # Install awscli
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        unzip awscliv2.zip
        aws/install
        rm -rf aws awscliv2.zip
        
        # Download installation file
        aws s3 cp  s3://0ed58e18-0c0c-11ed-861d-0242ac120003/jsonar-4.8.a.tar.gz .
        
        # Installation
        tar -xf  jsonar-4.8.a.tar.gz  -gz -C $DIR
        rm jsonar-4.8.a.tar.gz
        chown -R sonarw:sonar $DIR
        hostname ${var.hub_machine_name}
        /opt/sonar-dsf/jsonar/apps/4.8.a/bin/sonarg-setup --no-interactive --accept-eula --jsonar-uid-display-name "DSF-Hub" --jsonar-uid $(uuidgen) --not-remote-machine --product sonar-platform --newadmin-pass=my_password --secadmin-pass=my_password --sonarg-pass=my_password --sonargd-pass=my_password
    END
  }
}

resource "aws_instance" "dsf_hub_instance" {
  ami                         = var.hub_amis_id[var.aws_region]
  instance_type               = var.hub_instance_type
  key_name                    = var.hub_key_pair
  subnet_id                   = aws_subnet.public_subnet.id
  associate_public_ip_address = var.hub_public_ip
  user_data                   = data.template_cloudinit_config.sonar_config.rendered
  vpc_security_group_ids      = [aws_security_group.public.id]
  iam_instance_profile        = data.aws_iam_role.s3_full_read_access_profile.id
  tags = {
    Name = var.hub_machine_name
  }
  root_block_device {
    volume_type = var.hub_disk_type
    volume_size = var.hub_disk_size
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
# add time wait condition that waits until GUI is visible
# remove you role
# solve pem issue
# solve the package download issue
# propate random password to hub
# take password from vars
# Add additional logical volume for DSF hub files - this is an instance depended solution and therefore should be handled in the future
# make userdata run always to fix overcome issues that might be affected by a reboot or a disk change or a instance change - https://aws.amazon.com/premiumsupport/knowledge-center/execute-user-data-ec2/
