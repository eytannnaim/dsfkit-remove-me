resource "aws_eip" "dsf_gw_eip" {
  instance = aws_instance.dsf_hub_gw_instance.id
  vpc      = true
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

data "template_file" "federate_script" {
  template = file("${path.module}/federate.sh")
  vars = {
    dsf_hub_ip=aws_eip.dsf_hub_eip.public_ip
    dsf_gw_ip=aws_eip.dsf_gw_eip.public_ip
  }
}

resource "aws_instance" "dsf_hub_gw_instance" {
  ami           = var.hub_amis_id[var.aws_region]
  instance_type = var.dsf_hub_instance_type
  key_name      = aws_key_pair.dsf_hub_ssh_keypair.key_name
  subnet_id = aws_subnet.dsf_public_subnet.id
  # associate_public_ip_address = var.hub_public_ip
  user_data                   = data.template_file.gw_cloudinit.rendered
  iam_instance_profile = aws_iam_instance_profile.dsf_hub_instance_iam_profile.id
  # vpc_security_group_ids      = [aws_security_group.public.id]
  tags = {
    Name = "imperva-dsf-wg"
  }
  depends_on = [aws_secretsmanager_secret_version.dsf_hub_federation_public_key_ver, aws_secretsmanager_secret_version.dsf_hub_federation_private_key_ver]
}


data "template_file" "gw_cloudinit" {
  template = file("${path.module}/gw_cloudinit.tpl")
  vars = {
    admin_password=var.user_password
    secadmin_password=var.user_password
    sonarg_pasword=var.user_password
    sonargd_pasword=var.user_password
    dsf_hub_sonarw_public_ssh_key_name="dsf_hub_federation_public_key_${random_id.id.hex}"
  }
}