locals {

  common_tags = {
    Name        = var.name
    Environment = "production"
  }
  

  public_subnet_map = zipmap(var.public_subnet_cidrs, slice(var.availability_zones, 0, length(var.public_subnet_cidrs)))
  

  private_subnet_map = zipmap(var.private_subnet_cidrs, slice(var.availability_zones, 0, length(var.private_subnet_cidrs)))
}


resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = merge(local.common_tags, { Name = "${var.name}-vpc" })
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = merge(local.common_tags, { Name = "${var.name}-igw" })
}


resource "aws_subnet" "public" {
  for_each          = local.public_subnet_map
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.key
  availability_zone = each.value
  map_public_ip_on_launch = true # Best practice for public subnets
  tags = merge(local.common_tags, { Name = "${var.name}-public-subnet-${each.key}" })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = merge(local.common_tags, { Name = "${var.name}-public-rt" })
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}


resource "aws_subnet" "private" {
  for_each          = local.private_subnet_map
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.key
  availability_zone = each.value
  tags = merge(local.common_tags, { Name = "${var.name}-private-subnet-${each.key}" })
}


resource "aws_security_group" "ec2_sg" {
  name        = "${var.name}-ec2-sg"
  description = "Security group for EC2 instances"
  vpc_id      = aws_vpc.main.id


  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port    = 0
    to_port      = 0
    protocol     = "-1"
    cidr_blocks  = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${var.name}-ec2-sg" })
}


resource "aws_eip" "nat" {
  count  = length(var.private_subnet_cidrs)
  domain = "vpc"
  tags   = merge(local.common_tags, { Name = "${var.name}-nat-eip-${count.index}" })
}

resource "aws_nat_gateway" "main" {
  count         = length(var.private_subnet_cidrs)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = values(aws_subnet.public)[count.index].id

  tags = merge(local.common_tags, { Name = "${var.name}-nat-gw-${count.index}" })
  depends_on = [aws_internet_gateway.main]
}

resource "aws_route_table" "private" {
  count = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = merge(local.common_tags, { Name = "${var.name}-private-rt-${count.index}" })
}

resource "aws_route_table_association" "private" {
  count        = length(var.private_subnet_cidrs)
  subnet_id    = values(aws_subnet.private)[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
