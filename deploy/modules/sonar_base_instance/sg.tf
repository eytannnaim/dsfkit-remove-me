data "aws_subnet" "subnet" {
  id = var.subnet_id
}

locals {
  cidr_blocks   = concat(var.sg_ingress_cidr, ["${aws_eip.dsf_instance_eip.public_ip}/32"])
  ingress_ports = [ "22", "8080", "8443"]
  
  cidr_ingress_rules = distinct(flatten([
    for cidr in local.cidr_blocks : [
      for port in local.ingress_ports : {
        cidr = cidr
        port = port
      }
    ]
  ]))
  
  sg_ingress_rules = distinct(flatten([
    for sg in var.sg_ingress_sg : [
      for port in local.ingress_ports : {
        sg = sg
        port = port
      }
    ]
  ]))
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

resource "aws_security_group_rule" "sg_cidr_ingress" {
  for_each          = { for entry in local.cidr_ingress_rules: "${entry.cidr}.${entry.port}" => entry }
  type              = "ingress"
  from_port         = each.value.port
  to_port           = each.value.port
  protocol          = "tcp"
  cidr_blocks       = [each.value.cidr]
  security_group_id = aws_security_group.public.id
}

resource "aws_security_group_rule" "sg_sg_ingress" {
  for_each          = { for entry in local.sg_ingress_rules: "${entry.sg}.${entry.port}" => entry }
  type              = "ingress"
  from_port         = each.value.port
  to_port           = each.value.port
  protocol          = "tcp"
  source_security_group_id = each.value.sg
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

resource "aws_security_group_rule" "sonarrsyslog_self" {
  type              = "ingress"
  from_port         = 10800
  to_port           = 10899
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.public.id
}

resource "aws_security_group_rule" "sg_ingress_self" {
  for_each          = toset(local.ingress_ports)
  type              = "ingress"
  from_port         = tonumber("${each.key}")
  to_port           = tonumber("${each.key}")
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.public.id
}