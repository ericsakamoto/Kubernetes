resource "aws_vpc" "skmt_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "skmt_vpc"
  }
}

resource "aws_internet_gateway" "smkt_igw" {
  vpc_id = aws_vpc.skmt_vpc.id

  tags = {
    Name = "smkt_igw"
  }
}

resource "aws_subnet" "skmt_private_subnet" {
  vpc_id                  = aws_vpc.skmt_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = false
}

resource "aws_route_table" "skmt_route_table" {
  vpc_id = aws_vpc.skmt_vpc.id

  tags = {
    Name = "skmt_route_table"
  }
}

resource "aws_route" "skmt_route_1" {
  route_table_id            = aws_route_table.skmt_route_table.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.smkt_igw.id
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.skmt_private_subnet.id
  route_table_id = aws_route_table.skmt_route_table.id
}

resource "aws_subnet" "skmt_public_subnet" {
  vpc_id                  = aws_vpc.skmt_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  #availability_zone       = "${var.region}a"
  tags = {
    Name = "skmt_public_subnet"
  }
}

resource "aws_route_table" "skmt_public_route_table" {
  vpc_id = aws_vpc.skmt_vpc.id
  tags = {
    Name = "skmt_public_route_table"
  }
}

resource "aws_route" "skmt_public_route" {
  route_table_id         = aws_route_table.skmt_public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.smkt_igw.id
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.skmt_public_subnet.id
  route_table_id = aws_route_table.skmt_public_route_table.id
}

# VPC Endpoints for SSM
resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = aws_vpc.skmt_vpc.id
  service_name      = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [aws_subnet.skmt_private_subnet.id]
  security_group_ids = [aws_security_group.skmt_sg.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id            = aws_vpc.skmt_vpc.id
  service_name      = "com.amazonaws.${var.region}.ec2messages"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [aws_subnet.skmt_private_subnet.id]
  security_group_ids = [aws_security_group.skmt_sg.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id            = aws_vpc.skmt_vpc.id
  service_name      = "com.amazonaws.${var.region}.ssmmessages"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [aws_subnet.skmt_private_subnet.id]
  security_group_ids = [aws_security_group.skmt_sg.id]
  private_dns_enabled = true
}

# Region variable
variable "region" {
  default = "us-east-1"
}