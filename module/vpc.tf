##########################################
########### Demo VPC  ##############
##########################################

# Create a VPC for the demo server and pipeline
resource "aws_vpc" "demo_vpc" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_hostnames = "true"

  tags = {
    Name      = "i11-ci-demo-vpc"
    Terraform = "True"
  }
}

# Create public subnet in aza
resource "aws_subnet" "public_subnet_aza" {
  cidr_block        = "10.1.100.0/24"
  availability_zone = "ap-southeast-2a"
  vpc_id            = aws_vpc.demo_vpc.id

  tags = {
    Name      = "i11-ci-demo-vpc-public-subnet-aza"
    Terraform = "True"
  }
}

# Create public subnet in azb
resource "aws_subnet" "public_subnet_azb" {
  cidr_block        = "10.1.110.0/24"
  availability_zone = "ap-southeast-2b"
  vpc_id            = aws_vpc.demo_vpc.id

  tags = {
    Name      = "i11-ci-demo-vpc-public-subnet-azb"
    Terraform = "True"
  }
}

# Create public subnet in azc
resource "aws_subnet" "public_subnet_azc" {
  cidr_block        = "10.1.120.0/24"
  availability_zone = "ap-southeast-2c"
  vpc_id            = aws_vpc.demo_vpc.id

  tags = {
    Name      = "i11-ci-demo-vpc-public-subnet-azc"
    Terraform = "True"
  }
}

# Create private subnet in aza
resource "aws_subnet" "private_subnet_aza" {
  cidr_block        = "10.1.10.0/24"
  availability_zone = "ap-southeast-2a"
  vpc_id            = aws_vpc.demo_vpc.id

  tags = {
    Name      = "i11-ci-demo-vpc-private-subnet-aza"
    Terraform = "True"
  }
}

# Create private subnet in azb
resource "aws_subnet" "private_subnet_azb" {
  cidr_block        = "10.1.20.0/24"
  availability_zone = "ap-southeast-2b"
  vpc_id            = aws_vpc.demo_vpc.id

  tags = {
    Name      = "i11-ci-demo-vpc-private-subnet-azb"
    Terraform = "True"
  }
}

# Create private subnet in azc
resource "aws_subnet" "private_subnet_azc" {
  cidr_block        = "10.1.30.0/24"
  availability_zone = "ap-southeast-2c"
  vpc_id            = aws_vpc.demo_vpc.id

  tags = {
    Name      = "i11-ci-demo-vpc-private-subnet-azc"
    Terraform = "True"
  }
}

# Create an internet gateway to give internet access
resource "aws_internet_gateway" "demo_vpc_internet_gateway" {
  vpc_id = aws_vpc.demo_vpc.id

  tags = {
    Name      = "i11-ci-demo-igw"
    Terraform = "True"
  }
}

# Create a EIP for NAT Gateway
resource "aws_eip" "nat_gateway_eip" {
  vpc = true

  tags = {
    Name      = "demo_vpc_nat_gateway_eip"
    Terraform = "True"
  }
}

# Create NAT Gateway in AZB
resource "aws_nat_gateway" "demo_nat_gateway" {
  subnet_id     = aws_subnet.public_subnet_azb.id
  allocation_id = aws_eip.nat_gateway_eip.id

  tags = {
    Name      = "demo_vpc_nat_gateway"
    Terraform = "True"
  }

  depends_on = [aws_internet_gateway.demo_vpc_internet_gateway]
}

# Create a demo vpc public route table
resource "aws_route_table" "demo_pub_route_table" {
  vpc_id = aws_vpc.demo_vpc.id

  # Route to the internet
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo_vpc_internet_gateway.id
  }
  tags = {
    Name      = "demo_vpc_public_route_table"
    Terraform = "True"
  }
}

# Create a demo vpc private route table
resource "aws_route_table" "demo_private_route_table" {
  vpc_id = aws_vpc.demo_vpc.id

  # Route to the internet
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.demo_nat_gateway.id
  }
  tags = {
    Name      = "demo_vpc_private_route_table"
    Terraform = "True"
  }
}

# attach public subnets to route table
resource "aws_route_table_association" "demo_public_table_association_2a" {
  subnet_id      = aws_subnet.public_subnet_aza.id
  route_table_id = aws_route_table.demo_pub_route_table.id
}

resource "aws_route_table_association" "demo_public_table_association_2b" {
  subnet_id      = aws_subnet.public_subnet_azb.id
  route_table_id = aws_route_table.demo_pub_route_table.id
}

resource "aws_route_table_association" "demo_public_table_association_2c" {
  subnet_id      = aws_subnet.public_subnet_azc.id
  route_table_id = aws_route_table.demo_pub_route_table.id
}

# Attach private subnets to the route table
resource "aws_route_table_association" "demo_private_table_association_2a" {
  subnet_id      = aws_subnet.private_subnet_aza.id
  route_table_id = aws_route_table.demo_private_route_table.id
}

resource "aws_route_table_association" "demo_private_table_association_2b" {
  subnet_id      = aws_subnet.private_subnet_azb.id
  route_table_id = aws_route_table.demo_private_route_table.id
}

resource "aws_route_table_association" "demo_private_table_association_2c" {
  subnet_id      = aws_subnet.private_subnet_azc.id
  route_table_id = aws_route_table.demo_private_route_table.id
}