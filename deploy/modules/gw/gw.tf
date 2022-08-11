#resource "null_resource" "federate_exec" {
#  provisioner "local-exec" {
##    command = data.template_file.federate_script.rendered
#    command = "./federate.sh $HUB_IP $GW_IP"
#    interpreter = ["/bin/bash", "-c"]
#    environment = {
#      HUB_IP = aws_eip.dsf_hub_eip.public_ip
#      GW_IP = aws_eip.dsf_gw_eip.public_ip
#    }
#  }
#  depends_on = [aws_instance.dsf_hub_instance, aws_instance.dsf_hub_gw_instance]
#}
#
#data "template_file" "federate_script" {
#  template = file("${path.module}/federate.sh")
#  vars = {
#    dsf_hub_ip=aws_eip.dsf_hub_eip.public_ip
#    dsf_gw_ip=aws_eip.dsf_gw_eip.public_ip
#  }
#}

data "template_file" "gw_cloudinit" {
  template = file("${path.module}/gw_cloudinit.tpl")
  vars = {
    admin_password=var.admin_password
    secadmin_password=var.admin_password
    sonarg_pasword=var.admin_password
    sonargd_pasword=var.admin_password
    dsf_hub_sonarw_public_ssh_key_name="dsf_hub_federation_public_key_${var.name}"
  }
}

module "sonar_base_instance" {
  source = "../../modules/sonar_base_instance"
  region = var.region
  name = join("-", [var.name, "gw"])
  subnet_id = var.subnet_id
  ec2_user_data = data.template_file.gw_cloudinit.rendered
  key_pair = var.key_pair
  ec2_instance_type = var.instance_type
  ebs_state_disk_size = var.disk_size
}
