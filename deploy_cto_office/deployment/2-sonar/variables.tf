variable "vpc_id" { default = "vpc-12345-abcde" }
variable "subnet_id" { default = "subnet-12345-abcde" }
variable "availability_zone" { default = "us-east-2a" }
variable "dsf_version" { default = "4.x" }
variable "dsf_install_tarball_path" { default = "jsonar-4.x-12345-abcde.tar.gz" }
variable "ec2_instance_type" { default = "c5.4xlarge" } # "c5.4xlarge"
variable "sonar_image_name" { default = "your-dsf" }
variable "security_group_ingress_cidrs" { 
    type = list
    description = "List of allowed ingress cidr patterns for the DSF agentless gw instance."
    default = ["1.2.3.4/32", "172.20.0.0/16"] 
}

######################## Additional (optional) parameters ########################
# Use this param to specify any additional parameters for the initial setup, example syntax below
# { default = "--jsonar-logdir=\"/path/to/log/dir\" --smtp-ssl --ignore-system-warnings" }
# https://sonargdocs.jsonar.com/4.5/en/sonar-setup.html#noninteractive-setup
variable "additional_parameters" { default = "" }
