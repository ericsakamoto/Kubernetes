resource "aws_vpc" "skmt_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

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

resource "aws_subnet" "skmt_public_subnet" {
  vpc_id     = aws_vpc.skmt_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "sa-east-1a"

  tags = {
    Name = "skmt_public_subnet"
  }
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
  subnet_id      = aws_subnet.skmt_public_subnet.id
  route_table_id = aws_route_table.skmt_route_table.id
}