data "aws_subnet" "subnet" {
  id = var.subnet_id
}

resource "aws_security_group" "public" {
  name        = join("-", [var.name, "public", "sg"])
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
  cidr_blocks       = var.sg_ingress_cidr
  security_group_id = aws_security_group.public.id
}

resource "aws_security_group_rule" "public_in_http2" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = var.sg_ingress_cidr
  security_group_id = aws_security_group.public.id
}

resource "aws_security_group_rule" "public_in_https2" {
  type              = "ingress"
  from_port         = 8443
  to_port           = 8443
  protocol          = "tcp"
  cidr_blocks       = var.sg_ingress_cidr
  security_group_id = aws_security_group.public.id
}

resource "aws_security_group_rule" "public_all" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65000
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public.id
}
