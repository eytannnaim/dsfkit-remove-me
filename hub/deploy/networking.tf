resource "aws_vpc" "dsf_vpc" {
  cidr_block = var.dsf_vpc_cidr
}

resource "aws_subnet" "dsf_public_subnet" {
  vpc_id     = aws_vpc.dsf_vpc.id
  cidr_block = var.hub_dsf_public_subnet_cidr

  tags = {
    Name = "dsf-hub-public-subnet"
  }
}

resource "aws_subnet" "dsf_private_subnet" {
  vpc_id     = aws_vpc.dsf_vpc.id
  cidr_block = var.hub_dsf_private_subnet_cidr

  tags = {
    Name = "dsf-hub-private-subnet"
  }
}

resource "aws_security_group" "public" {
  name        = "dsf-hub-public-sg"
  description = "Public internet access"
  vpc_id      = aws_vpc.dsf_vpc.id

  tags = {
    Name = "dsf-hub-public-sg"
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
  cidr_blocks       = var.vpn_security_group_cidr
  security_group_id = aws_security_group.public.id
}

resource "aws_security_group_rule" "public_in_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = var.vpn_security_group_cidr
  security_group_id = aws_security_group.public.id
}

resource "aws_security_group_rule" "public_in_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = var.vpn_security_group_cidr
  security_group_id = aws_security_group.public.id
}


resource "aws_security_group_rule" "public_in_https2" {
  type              = "ingress"
  from_port         = 8443
  to_port           = 8443
  protocol          = "tcp"
  cidr_blocks       = var.vpn_security_group_cidr
  security_group_id = aws_security_group.public.id
}


resource "aws_internet_gateway" "dsf_internet_gw" {
  vpc_id = aws_vpc.dsf_vpc.id

  tags = {
    Name = "dsf-hub-public-gw"
  }
}

resource "aws_network_interface_sg_attachment" "dsf_sg_attachment" {
  security_group_id    = aws_security_group.public.id
  network_interface_id = aws_instance.dsf_hub_instance.primary_network_interface_id
}

resource "aws_route_table" "sonar-hub-public-rt" {
  vpc_id = aws_vpc.dsf_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dsf_internet_gw.id
  }
}

resource "aws_route_table_association" "dsf_public_subnet_route_table_association" {
  subnet_id      = aws_subnet.dsf_public_subnet.id
  route_table_id = aws_route_table.sonar-hub-public-rt.id
}
