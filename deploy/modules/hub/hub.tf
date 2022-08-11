data "template_file" "hub_cloudinit" {
  template = file("${path.module}/hub_cloudinit.tpl")
  vars = {
    admin_password=var.admin_password
    secadmin_password=var.admin_password
    sonarg_pasword=var.admin_password
    sonargd_pasword=var.admin_password
    dsf_hub_sonarw_private_ssh_key_name="dsf_hub_federation_private_key_${var.name}"
    dsf_hub_sonarw_public_ssh_key_name="dsf_hub_federation_public_key_${var.name}"
  }
}

module "sonar_base_instance" {
  source = "../../modules/sonar_base_instance"

  region = var.region
  
  name = var.name
  
  subnet_id = var.subnet_id
  
  ec2_user_data = data.template_file.hub_cloudinit.rendered
  
  ec2_instance_type = var.dsf_hub_instance_type
  
  ebs_state_disk_size = var.dsf_hub_disk_size
}