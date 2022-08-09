resource "aws_eip" "dsf_gw_eip" {
  instance = aws_instance.dsf_hub_gw_instance.id
  vpc      = true
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
    #admin_password=jsondecode(data.aws_secretsmanager_secret_version.sonar-secrets.secret_string)["admin_password"]
    #secadmin_password=jsondecode(data.aws_secretsmanager_secret_version.sonar-secrets.secret_string)["secadmin_password"]
    #sonarg_pasword=jsondecode(data.aws_secretsmanager_secret_version.sonar-secrets.secret_string)["sonarg_pasword"]
    #sonargd_pasword=jsondecode(data.aws_secretsmanager_secret_version.sonar-secrets.secret_string)["sonargd_pasword"]
    admin_password="Imp3rva12#"
    secadmin_password="Imp3rva12#"
    sonarg_pasword="Imp3rva12#"
    sonargd_pasword="Imp3rva12#"
  }
}