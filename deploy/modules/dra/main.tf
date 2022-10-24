data "template_file" "admin_bootstrap" {
  template = file("${path.module}/admin_bootstrap.tpl")
  vars = {
    registration_password = var.registration_password
  }
}

data "template_file" "analytics_bootstrap" {
  template = file("${path.module}/analytics_bootstrap.tpl")
  vars = {
    registration_password = var.registration_password
    analytics_user = var.analytics_user
    analytics_password = var.analytics_password
    admin_server_ip = aws_instance.admin_server.private_ip
  }
}
resource "aws_instance" "admin_server" {
  ami           = var.admin_ami_id
  instance_type = var.instance_type
  subnet_id = module.vpc.public_subnets[0]
  vpc_security_group_ids = ["${aws_security_group.admin-server-demo.id}"]
  key_name = var.key
  user_data = data.template_file.admin_bootstrap.rendered

  tags = {
    Name = "DRA-Admin-server"
    stage = "Test"
  }
}

resource "aws_instance" "analytics_server" {
  ami           = var.analytics_ami_id
  instance_type = var.instance_type
  subnet_id = module.vpc.private_subnets[0]
  vpc_security_group_ids = ["${aws_security_group.analytics-server-demo.id}"]
  key_name = var.key
  user_data = data.template_file.analytics_bootstrap.rendered
  tags = {
    Name = "DRA-Analytics-server"
    stage = "Test"
  }
}

output "admin_server_url" {
  value = "https://${aws_instance.admin_server.public_ip}:8443"
}

# Check for Sonar variables:
#   1. Configure scp job to receieve audit data
#              
#   2. Configure listener on gateway for DRA to send events to 


# resource "aws_instance" "jump_server" {
#   ami           = data.aws_ssm_parameter.centOS.value
#   instance_type = var.instance_type
#   subnet_id = aws_subnet.public-1.id
#   vpc_security_group_ids = ["${aws_security_group.jump_server.id}"]
#   user_data = file ("./bootstrap_jumpserver.sh")
#   key_name = var.key

#   tags = {
#     Name = "Jump-Server-on-centos"
#     stage = "Test"
#   }
# }
# # ----------- Output the public ID of the Web Server ----------------

# output "web" {
#   value = [aws_instance.web.private_ip]
# }


