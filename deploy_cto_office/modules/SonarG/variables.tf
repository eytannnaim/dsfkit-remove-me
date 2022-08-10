variable "profile" { default = "octo" }
variable "environment" { default = "dev" }
variable "sonar_secrets" { default = "dev/sonar" }
variable "region" { default = "us-east-2" }
variable "vpc_id" { default = "vpc-06ee2eb1ae2e196dd" }
variable "subnet_id" { default = "subnet-0f25157d66b6703f3" }
variable "availability_zone" { default = "us-east-2a" }
variable "key_pair" { default = "isbt-key-20200608235850" }
variable "s3_bucket" { default = "octo-sonar-configs2" }
variable "sonar_version" { default = "4.9.servicenow" }
variable "sonar_install_file" { default = "sonarfinder-4.10.0-devel-1-gaf9f18c7c0.tar.gz" }
variable "sonar_image_name" { default = "sonar-wh1-dev-ba" }
variable "security_group_ingress" { default = ["70.95.57.19/32", "172.20.0.0/16"] }
variable "sonar_aws_ebs_volume_size" { default = 100 }
variable "public_ssh_key_path" { default = "keys/id_rsa_sonar_dev.pub" }
variable "private_ssh_key_path" { default = "keys/id_rsa_sonar_dev" }
variable "sonarw_ip" { default = "" }

######################## Additional (optional) parameters ########################
# Use this param to specify any additional parameters for the initial setup, example syntax below
# { default = "--jsonar-logdir=\"/path/to/log/dir\" --smtp-ssl --ignore-system-warnings" }
# https://sonargdocs.jsonar.com/4.5/en/sonar-setup.html#noninteractive-setup
variable "additional_parameters" { default = "" }

# ALB vars below
variable "sonar-admin-port" { default = 8443 }
variable "dns-name" { default = "dev.impervademo.com" }
