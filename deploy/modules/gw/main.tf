resource "null_resource" "federate_exec" {
  provisioner "local-exec" {
    command         = "${path.module}/federate.sh $HUB_IP $GW_IP"
    interpreter     = ["/bin/bash", "-c"]
    environment = {
      HUB_IP = var.hub_ip
      GW_IP  = module.gw_instance.instance_eip
    }
  }
  depends_on = [module.gw_instance]
}

data "template_file" "gw_cloudinit" {
  template = file("${path.module}/gw_cloudinit.tpl")
  vars = {
    admin_password      = var.admin_password
    secadmin_password   = var.admin_password
    sonarg_pasword      = var.admin_password
    sonargd_pasword     = var.admin_password
    display-name        = "DSF-gw-${var.name}"
    federation_public_key = var.federation_public_key
  }
}

module "gw_instance" {
  source                = "../../modules/sonar_base_instance"
  name                  = join("-", [var.name, "gw"])
  subnet_id             = var.subnet_id
  ec2_user_data         = data.template_file.gw_cloudinit.rendered
  key_pair              = var.key_pair
  ec2_instance_type     = var.instance_type
  ebs_state_disk_size   = var.disk_size
  sg_ingress_cidr       = var.sg_ingress_cidr
}
