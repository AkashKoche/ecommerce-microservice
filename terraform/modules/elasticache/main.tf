resource "aws_security_group" "redis_sg" {
  name        = "${var.name}-redis-sg"
  vpc_id      = var.vpc_id
  description = "Allows access to Redis from application servers"

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [var.app_security_group_id]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-Redis-SG"
  }
}


resource "aws_elasticache_subnet_group" "main" {
  name        = "${var.name}-cache-subnet-group"
  subnet_ids  = var.private_subnet_ids
  description = "Subnets for Redis deployment"
}


resource "aws_elasticache_cluster" "redis" {
  cluster_id              = var.name
  engine                  = "redis"
  node_type               = "cache.t3.micro"
  num_cache_nodes         = 1
  parameter_group_name    = "default.redis7"
  port                    = 6379
  security_group_ids      = [aws_security_group.redis_sg.id]
  subnet_group_name       = aws_elasticache_subnet_group.main.name
  
  tags = {
    Name = var.name
  }
}
