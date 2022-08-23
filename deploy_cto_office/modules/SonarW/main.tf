#################################
# Hub cloudinit script (AKA userdata)
#################################

data "template_file" "hub_cloudinit" {
  template = file("${path.module}/hub_cloudinit.tpl")
  vars = {
    admin_password                      = var.admin_password
    secadmin_password                   = var.secadmin_password
    sonarg_pasword                      = var.sonarg_pasword
    sonargd_pasword                     = var.sonargd_pasword
    federation_public_key_name          = var.federation_public_key_name
    federation_private_key_name         = var.federation_private_key_name
    s3_bucket                           = var.s3_bucket
    dsf_version                         = var.dsf_version
    dsf_install_tarball_path            = var.dsf_install_tarball_path
    additional_parameters               = var.additional_parameters
  }
}

#################################
# Actual Hub instance
#################################

module "hub_instance" {
  source                         = "../../modules/sonar_base_instance"
  name                           = var.name
  subnet_id                      = var.subnet_id
  ec2_user_data                  = data.template_file.hub_cloudinit.rendered
  key_pair                       = var.key_pair
  ec2_instance_type              = var.ec2_instance_type
  ebs_disk_size                  = var.ebs_disk_size
  security_group_ingress_cidrs   = var.security_group_ingress_cidrs
  dsf_iam_profile_name           = var.dsf_iam_profile_name
}