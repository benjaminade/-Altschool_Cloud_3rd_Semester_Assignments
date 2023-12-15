# Lets create a vpc
resource "aws_vpc" "dev-vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "${var.environment}-vpc"
  }
}

# Use data to get availability zones
data "aws_availability_zones" "availability_zones" {}

# Create a subnet
resource "aws_subnet" "dev-subnet" {
  count = 2
  cidr_block = var.subnet_cidr[count.index]
  vpc_id = aws_vpc.dev-vpc.id
  availability_zone = data.aws_availability_zones.availability_zones.names[count.index]
  map_public_ip_on_launch = var.map_public_ip_on_launch_true_false

  tags = {
    Name = "${var.environment}-subnet-${count.index +1}"
  }
}

# create an internet gateway
resource "aws_internet_gateway" "dev-vpc-igw" {
  vpc_id = aws_vpc.dev-vpc.id
}

# Create a route table
resource "aws_route_table" "dev-vpc-route-table" {
  vpc_id = aws_vpc.dev-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev-vpc-igw.id
  }

  tags = {
    Name = "${var.environment}-route-table}"
  }
}

resource "aws_route_table_association" "dev-subnet-associate" {
  count = 2
  route_table_id = aws_route_table.dev-vpc-route-table.id
  subnet_id = aws_subnet.dev-subnet[count.index].id
}

# create key pair for the instance
resource "aws_key_pair" "testkey" {
  key_name = var.key_pair_name
  public_key = tls_private_key.rsa.public_key_openssh
}

# Create a private key
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits = 4096
}

# Put the private key in a local file
resource "local_file" "testkey_private" {
  content = tls_private_key.rsa.private_key_pem
  filename = var.private-key-filename
}