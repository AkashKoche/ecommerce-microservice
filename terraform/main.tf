terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
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
  tags = {
    Name = "main-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "ecommerce-public-rt"
  }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "Private-Subnet-${count.index + 1}"
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
    cidr_blocks = ["0.0.0.0/0"]
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


resource "aws_security_group" "rds_sg" {
  name        = "rds-postgres-sg"
  vpc_id      = aws_vpc.main.id
  description = "Allow access to Postgres from application servers"

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }
}

resource "aws_db_subnet_group" "main" {
  name       = "main-rds-subnet-group"
  subnet_ids = aws_subnet.private[*].id
  tags = {
    Name = "Main RDS Subnet Group"
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

resource "aws_security_group" "redis_sg" {
  name        = "redis-cache-sg"
  vpc_id      = aws_vpc.main.id
  description = "Allows access to Redis from application servers"

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Redis-Security-Group"
  }
}

resource "aws_elasticache_subnet_group" "main" {
  name       = "redis-subnet-group"
  subnet_ids = aws_subnet.private[*].id 
  description = "Subnets for Redis deployment"
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id              = "ecommerce-redis"
  engine                  = "redis"
  node_type               = "cache.t3.micro"
  num_cache_nodes         = 1
  parameter_group_name    = "default.redis7"
  port                    = 6379
  security_group_ids      = [aws_security_group.redis_sg.id]
  subnet_group_name       = aws_elasticache_subnet_group.main.name

  tags = {
    Name = "ecommerce-redis"
  }
}
