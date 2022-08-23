########################################################
###############  SonarG Instance Configs ###############
########################################################

resource "null_resource" "federate_exec" {
  provisioner "local-exec" {
    command         = "chmod +x ${path.module}/federate.sh && ${path.module}/federate.sh $HUB_IP $GW_IP $DSF_VERSION"
    interpreter     = ["/bin/bash", "-c"]
    environment = {
      HUB_IP = var.hub_ip
      GW_IP  = module.gw_instance.private_ip
      DSF_VERSION = var.dsf_version
    }
  }
  depends_on = [module.gw_instance]
}

data "template_file" "gw_cloudinit" {
  template = file("${path.module}/gw_cloudinit.tpl")
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

module "gw_instance" {
  source                       = "../../modules/sonar_base_instance"
  name                         = var.name
  subnet_id                    = var.subnet_id
  ec2_user_data                = data.template_file.gw_cloudinit.rendered
  key_pair                     = var.key_pair
  ec2_instance_type            = var.ec2_instance_type
  ebs_disk_size                = var.ebs_disk_size
  security_group_ingress_cidrs = var.security_group_ingress_cidrs
  dsf_iam_profile_name         = var.dsf_iam_profile_name
}