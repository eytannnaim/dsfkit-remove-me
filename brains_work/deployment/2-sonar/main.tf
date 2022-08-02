provider "aws" {
  region = var.region
}

module "sonarw" {
  source  = "../modules/SonarW"
	profile = var.profile
	environment = var.environment
	sonar_secrets = var.sonar_secrets
	region = var.region
	vpc_id = var.vpc_id
	subnet_id = var.subnet_id
	availability_zone = var.availability_zone
	key_pair = var.key_pair
	s3_bucket = var.s3_bucket
	sonar_version = var.sonar_version
	sonar_install_file = var.sonar_install_file
	sonar_image_name = var.sonar_image_name
	security_group_ingress = var.security_group_ingress
	sonar_aws_ebs_volume_size = var.sonar_aws_ebs_volume_size
}

module "sonarg1" {
  source  = "../modules/SonarG"
	profile = var.profile
	environment = var.environment
	sonar_secrets = var.sonar_secrets
	region = var.region
	vpc_id = var.vpc_id
	subnet_id = var.subnet_id
	availability_zone = var.availability_zone
	key_pair = var.key_pair
	s3_bucket = var.s3_bucket
	sonar_version = var.sonar_version
	sonar_install_file = var.sonar_install_file
	sonar_image_name = var.sonar_image_name
	security_group_ingress = var.security_group_ingress
	sonar_aws_ebs_volume_size = var.sonar_aws_ebs_volume_size
  sonarw_ip=modules.sonarw.outputs.mx-ip
}

module "sonarg2" {
  source  = "../modules/SonarG"
	profile = var.profile
	environment = var.environment
	sonar_secrets = var.sonar_secrets
	region = var.region
	vpc_id = var.vpc_id
	subnet_id = var.subnet_id
	availability_zone = var.availability_zone
	key_pair = var.key_pair
	s3_bucket = var.s3_bucket
	sonar_version = var.sonar_version
	sonar_install_file = var.sonar_install_file
	sonar_image_name = var.sonar_image_name
	security_group_ingress = var.security_group_ingress
	sonar_aws_ebs_volume_size = var.sonar_aws_ebs_volume_size
  sonarw_ip=modules.sonarw.outputs.mx-ip
}
