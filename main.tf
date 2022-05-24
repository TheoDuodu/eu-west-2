#creating AWS network for a project 

resource "aws_vpc" "Project-VPC" {
  cidr_block           = var.vpc-cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Project-VPC1"
  }
}

#creating public subnet 1

resource "aws_subnet" "Prod-pub-sub1" {
  vpc_id            = aws_vpc.Project-VPC.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.az

  tags = {
    Name = "Prod-pub-sub1"
  }
}

#creating public subnet 2

resource "aws_subnet" "Prod-pub-sub2" {
  vpc_id            = aws_vpc.Project-VPC.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = var.az

  tags = {
    Name = "Prod-pub-sub2"
  }
}

#creating public subnet 3

resource "aws_subnet" "Prod-pub-sub3" {
  vpc_id     = aws_vpc.Project-VPC.id
  cidr_block = "10.0.3.0/24"

  availability_zone = var.az
  tags = {
    Name = "Prod-pub-sub3"
  }
}

#creating private subnet 1

resource "aws_subnet" "Prod-priv-sub1" {
  vpc_id     = aws_vpc.Project-VPC.id
  cidr_block = "10.0.4.0/24"

  availability_zone = var.az
  tags = {
    Name = "Prod-priv-sub1"
  }
}

#creating private subnet 2

resource "aws_subnet" "Prod-priv-sub2" {
  vpc_id     = aws_vpc.Project-VPC.id
  cidr_block = "10.0.5.0/24"

  availability_zone = var.az
  tags = {
    Name = "Prod-priv-sub2"
  }
}

#creating a public route table 

resource "aws_route_table" "prod-pub-route-table" {
  vpc_id = aws_vpc.Project-VPC.id

  tags = {
    Name = "prod-pub-route-table"
  }
}

#creating a private route table 

resource "aws_route_table" "prod-priv-route-table" {
  vpc_id = aws_vpc.Project-VPC.id

  tags = {
    Name = "prod-priv-route-table"
  }
}

#associating public route table with public subnet 1

resource "aws_route_table_association" "Prod-public-assoc1" {
  subnet_id      = aws_subnet.Prod-pub-sub1.id
  route_table_id = aws_route_table.prod-pub-route-table.id
}

#associating public route table with public subnet 2

resource "aws_route_table_association" "Prod-public-assoc2" {
  subnet_id      = aws_subnet.Prod-pub-sub2.id
  route_table_id = aws_route_table.prod-pub-route-table.id
}

#associating public route table with public subnet 3

resource "aws_route_table_association" "Prod-public-assoc3" {
  subnet_id      = aws_subnet.Prod-pub-sub3.id
  route_table_id = aws_route_table.prod-pub-route-table.id
}

#associating private route table with private subnet 1

resource "aws_route_table_association" "Prod-priv-assoc1" {
  subnet_id      = aws_subnet.Prod-priv-sub1.id
  route_table_id = aws_route_table.prod-priv-route-table.id
}

#associating private route table with private subnet 2

resource "aws_route_table_association" "Prod-priv-assoc2" {
  subnet_id      = aws_subnet.Prod-priv-sub2.id
  route_table_id = aws_route_table.prod-priv-route-table.id
}

#creating internet gateway

resource "aws_internet_gateway" "Prod-igw" {
  vpc_id = aws_vpc.Project-VPC.id

  tags = {
    Name = "Prod-IGW"
  }
}

#Associate  internet gateway with the public route table

resource "aws_route" "Prod-igw-association" {
  route_table_id         = aws_route_table.prod-pub-route-table.id
  gateway_id             = aws_internet_gateway.Prod-igw.id
  destination_cidr_block = "0.0.0.0/0"
}

#create Elastic IP

resource "aws_eip" "Prod-EIP" {
  vpc = true
}

#Creating NAT gateway.

resource "aws_nat_gateway" "Prod-Nat-gateway" {
  allocation_id = aws_eip.Prod-EIP.id
  subnet_id     = aws_subnet.Prod-pub-sub1.id

  tags = {
    Name = "Prod-Nat-gateway"
  }
}

#Associating NATgateway with private route table

resource "aws_route" "prod-Nat-association" {
  route_table_id         = aws_route_table.prod-priv-route-table.id
  nat_gateway_id         = aws_nat_gateway.Prod-Nat-gateway.id
  destination_cidr_block = "0.0.0.0/0"
}