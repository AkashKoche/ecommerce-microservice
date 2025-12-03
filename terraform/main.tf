terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~ 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main" {
  cidr_block         = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "ecommerce-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id               = aws_vpc.main.id
  cidr_block           = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    Name = "ecommerce-public-subnet"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  router {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "ecommerce-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id         = aws_subnet.public.id
  route_table_id    = aws_route_table.public.id
}

resource "aws_security_group" "ec2_sg" {
  name = "ecommerce-ec2-sg"
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
    cidr_protocol = ["0.0.0.0/0"]
  }

  egress {
    from_port    = 0
    to_port      = 0
    protocol     = "-1"
    cidr_blocks  = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecommerce-ec2-sg"
  }
}

resource "aws_db_instance" "postgres" {
  identifier             = "ecommerce-postgres"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "13.14"
  username               = "postgres"
  password               = var.db_password
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  skip_final_snapshot    = true
  publicly_accessible    = false
  tags = {
    Name = "ecommerce-postgres"
  }
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id              = "ecommerce-redis"
  engine                  = "redis"
  node_type               = "cache.t3.micro"
  num_cache_nodes         = 1
  parameter_group_name    = "default.redis7"
  port                    = 6379
  security_group_ids      = [aws_security_group.redis_sg.id]
  security_group_name     = aws_elasticache_subnet_group.main.name
  tags = {
    Name = "ecommerce-redis"
  }
}
