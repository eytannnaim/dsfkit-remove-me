data "aws_subnet" "subnet" {
  id = var.subnet_id
}

locals {
  cidr_blocks = concat(var.sg_ingress_cidr, ["${aws_eip.dsf_instance_eip.public_ip}/32"])
}

resource "aws_security_group" "public" {
  description = "Public internet access"
  vpc_id      = data.aws_subnet.subnet.vpc_id

  tags = {
    Name = join("-", [var.name, "sg"])
  }
}

resource "aws_security_group_rule" "public_out" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.public.id
}

resource "aws_security_group_rule" "public_in_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = local.cidr_blocks
  security_group_id = aws_security_group.public.id
}

resource "aws_security_group_rule" "public_in_http2" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = local.cidr_blocks
  security_group_id = aws_security_group.public.id
}

resource "aws_security_group_rule" "public_in_https2" {
  type              = "ingress"
  from_port         = 8443
  to_port           = 8443
  protocol          = "tcp"
  cidr_blocks       = local.cidr_blocks
  security_group_id = aws_security_group.public.id
}

resource "aws_security_group_rule" "sonarrsyslog" {
  type              = "ingress"
  from_port         = 10800
  to_port           = 10899
  protocol          = "tcp"
  cidr_blocks       = ["${aws_eip.dsf_instance_eip.public_ip}/32"]
  security_group_id = aws_security_group.public.id
}

#resource "aws_security_group_rule" "public_all" {
#  type              = "ingress"
#  from_port         = 0
#  to_port           = 65000
#  protocol          = "tcp"
#  cidr_blocks       = ["0.0.0.0/0"]
#  security_group_id = aws_security_group.public.id
#}
