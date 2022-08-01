resource "aws_vpc" "hub_vpc" {
  cidr_block = var.hub_vpc_cidr

}

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.hub_vpc.id
  cidr_block = var.hub_public_subnet_cidr

  tags = {
    Name = "sonar-hub-public-subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.hub_vpc.id
  cidr_block = var.hub_private_subnet_cidr

  tags = {
    Name = "sonar-hub-private-subnet"
  }
}

resource "aws_security_group" "public" {
  name        = "sonar-hub-public-sg"
  description = "Public internet access"
  vpc_id      = aws_vpc.hub_vpc.id

  tags = {
    Name = "sonar-hub-public-sg"
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
  cidr_blocks       = var.security_group_ingress
  security_group_id = aws_security_group.public.id
}

resource "aws_security_group_rule" "public_in_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = var.security_group_ingress
  security_group_id = aws_security_group.public.id
}

resource "aws_security_group_rule" "public_in_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = var.security_group_ingress
  security_group_id = aws_security_group.public.id
}

resource "aws_security_group_rule" "public_in_https2" {
  type              = "ingress"
  from_port         = 8443
  to_port           = 8443
  protocol          = "tcp"
  cidr_blocks       = var.security_group_ingress
  security_group_id = aws_security_group.public.id
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.hub_vpc.id

  tags = {
    Name = "sonar-hub-public-gw"
  }
}

resource "aws_route_table" "sonar-hub-public-rt" {
  vpc_id = aws_vpc.hub_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "public_subnet_route_table_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.sonar-hub-public-rt.id
}