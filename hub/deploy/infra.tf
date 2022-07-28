resource "aws_vpc" "hub_vpc" {
  cidr_block =  var.hub_vpc_cidr
  
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

resource "aws_instance" "sonar_hub_instance" {
  ami           = var.hub_amis_id[var.aws_region]
  instance_type = var.hub_instance_type
  key_name = aws_key_pair.deployer.key_name
  
subnet_id = aws_subnet.public_subnet.id
  tags = {
    Name = "sonar-hub"
  }
}

 resource "aws_eip" "sonar_hub_eip" {
  instance = aws_instance.sonar_hub_instance.id
  vpc      = true
}

resource "aws_key_pair" "deployer" {
  key_name   = "hub-key-pair"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCuEr/yHjzIXunGOPrLkLFjZ6Cns/8nOoGQApMAJp1sk6ZUq85TmTeaMM38nI037azJoytp6M4S3qRMZuw6VJlGmIY+23Mg7vkJlVBK0bc0CYZuiRm4g3XiNUxihyxDFSdbaDctuq25U8uRj04aG/pwAVWOG+ZN0b2bUqMDDtZKx19pjCY7TY/BRCwV88MTekFeqThfJiIS9HFikbjF85pjTTSPq/cWVjeb38PDmCxpfEZMRPjJxcay6MD8JcIH0yprnG11Kw5UFenQGP4VCrvO3zA+IpH3YPIqNpbXIND8cMT/90iFTiMuUULZ7AJAZ62sg4+iZmPniK0wZQZasXTttaV/GNj/nlo0PIkl+D1g5YocsICpsImG5s7WPruz02ICcWjSOSFpye/Uvj7E3XpHnj/gXGCM7Y69A/3x0GxqBvPsM3G62odnlZMHnfVk+3f1e6UjGV/k6EU3YvuQZyjif0xxQNOaYMorApIhmlgXnKFQOCDxHHHh3xFiYNX2iHM= gabi.beyo@MBP-175553.local"
}


resource "aws_security_group" "public" {
  name = "sonar-hub-public-sg"
  description = "Public internet access"
  vpc_id = aws_vpc.hub_vpc.id
 
  tags = {
    Name  = "sonar-hub-public-sg"
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
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public.id
}
 
resource "aws_security_group_rule" "public_in_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public.id
}
 
resource "aws_security_group_rule" "public_in_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public.id
}
 


resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.hub_vpc.id

  tags = {
    Name = "sonar-hub-public-gw"
  }
}

resource "aws_network_interface_sg_attachment" "sg_attachment" {
  security_group_id    = aws_security_group.public.id
  network_interface_id = aws_instance.sonar_hub_instance.primary_network_interface_id
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