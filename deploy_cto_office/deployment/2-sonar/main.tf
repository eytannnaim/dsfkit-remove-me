provider "aws" {
	region = data.terraform_remote_state.init.outputs.region
}

data "terraform_remote_state" "init" {
	backend = "local"
	config = {
		path = "${path.module}/../1-init/terraform.tfstate"
	}
}

data "aws_secretsmanager_secret" "dsf_passwords" {
  name = data.terraform_remote_state.init.outputs.dsf_passwords_secret_name
}

data "aws_secretsmanager_secret_version" "dsf_passwords" {
  secret_id = data.aws_secretsmanager_secret.dsf_passwords.id
}

module "sonarw" {
	source  = "../../modules/sonarw"
	region = data.terraform_remote_state.init.outputs.region
	name = "${data.terraform_remote_state.init.outputs.environment}-imperva-dsf-hub"
	subnet_id = var.subnet_id
	key_pair = data.terraform_remote_state.init.outputs.key_pair
	s3_bucket = data.terraform_remote_state.init.outputs.s3_bucket
	ec2_instance_type = var.ec2_instance_type
	ebs_disk_size = 500
	dsf_version = var.dsf_version
	dsf_install_tarball_path = var.dsf_install_tarball_path
	security_group_ingress_cidrs = var.security_group_ingress_cidrs
	federation_public_key_name = data.terraform_remote_state.init.outputs.dsf_hub_sonarw_public_ssh_key_name
	federation_private_key_name = data.terraform_remote_state.init.outputs.dsf_hub_sonarw_private_ssh_key_name
	dsf_iam_profile_name = data.terraform_remote_state.init.outputs.dsf_iam_profile_name
	admin_password = jsondecode(data.aws_secretsmanager_secret_version.dsf_passwords.secret_string)["admin_password"]
	secadmin_password = jsondecode(data.aws_secretsmanager_secret_version.dsf_passwords.secret_string)["secadmin_password"]
	sonarg_pasword = jsondecode(data.aws_secretsmanager_secret_version.dsf_passwords.secret_string)["sonarg_pasword"]
	sonargd_pasword = jsondecode(data.aws_secretsmanager_secret_version.dsf_passwords.secret_string)["sonargd_pasword"]
}

module "sonarg1" {
	source  = "../../modules/sonarg"
	depends_on = [
	  module.sonarw.private_ip
	]
	region = data.terraform_remote_state.init.outputs.region
	name = "${data.terraform_remote_state.init.outputs.environment}-imperva-dsf-agentless-gw"
	subnet_id = var.subnet_id
	key_pair = data.terraform_remote_state.init.outputs.key_pair
	s3_bucket = data.terraform_remote_state.init.outputs.s3_bucket
	ec2_instance_type = var.ec2_instance_type
	ebs_disk_size = 150
	dsf_version = var.dsf_version
	dsf_install_tarball_path = var.dsf_install_tarball_path
	security_group_ingress_cidrs = var.security_group_ingress_cidrs
	federation_public_key_name = data.terraform_remote_state.init.outputs.dsf_hub_sonarw_public_ssh_key_name
	federation_private_key_name = data.terraform_remote_state.init.outputs.dsf_hub_sonarw_private_ssh_key_name
	dsf_iam_profile_name = data.terraform_remote_state.init.outputs.dsf_iam_profile_name
	admin_password = jsondecode(data.aws_secretsmanager_secret_version.dsf_passwords.secret_string)["admin_password"]
	secadmin_password = jsondecode(data.aws_secretsmanager_secret_version.dsf_passwords.secret_string)["secadmin_password"]
	sonarg_pasword = jsondecode(data.aws_secretsmanager_secret_version.dsf_passwords.secret_string)["sonarg_pasword"]
	sonargd_pasword = jsondecode(data.aws_secretsmanager_secret_version.dsf_passwords.secret_string)["sonargd_pasword"]
	hub_ip = module.sonarw.private_ip
}

# module "sonarg2" {
#   source  = "../../modules/sonarg"
# 	profile = var.profile
# 	environment = var.environment
# 	sonar_secrets = var.sonar_secrets
# 	region = "us-west-1"
# 	vpc_id = var.vpc_id
# 	subnet_id = var.subnet_id
# 	availability_zone = var.availability_zone
# 	key_pair = var.key_pair
# 	s3_bucket = var.s3_bucket
# 	sonar_version = var.sonar_version
# 	sonar_install_file = var.sonar_install_file
# 	sonar_image_name = var.sonar_image_name
# 	security_group_ingress = var.security_group_ingress
# 	sonar_aws_ebs_volume_size = var.sonar_aws_ebs_volume_size
#   sonarw_ip=modules.sonarw.outputs.mx-ip
# }
