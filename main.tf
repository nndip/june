
provider "aws" {
  region  = "us-east-1"
}


resource "aws_vpc" "vpc" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name        = "devops-vpc-june"
    Environment = "dev"  }
}


resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "devops-igw-june"
    Environment = "dev"
  }
}

resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.ig]
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(aws_subnet.public_subnet.*.id, 0)
  depends_on    = [aws_internet_gateway.ig]
  tags = {
    Name        = "devops-nat-june"
    Environment = "dev"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = 1
  cidr_block              = "10.10.6.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name        = "devops-public-subnet-june"
    Environment = "dev"
  }
}

resource "aws_security_group" "default" {
  name        = "devops-sg"
  description = "class security group to allow inbound/outbound from the VPC"
  vpc_id      = aws_vpc.vpc.id
  depends_on  = [aws_vpc.vpc]
  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }
  
  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = "true"
  }
  tags = {
    Name = "devops-sg"
    Environment = "dev"
  }
}



output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnets_id" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.public_subnet.*.id
}
