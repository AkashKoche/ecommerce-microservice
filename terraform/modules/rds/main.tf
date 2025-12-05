resource "aws_security_group" "rds_sg" {
  name        = "${var.name}-rds-sg"
  vpc_id      = var.vpc_id
  description = "Allow access to Postgres from application servers"


  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.app_security_group_id]
  }
}


resource "aws_db_subnet_group" "main" {
  name       = "${var.name}-rds-subnet-group"
  subnet_ids = var.private_subnet_ids
  tags = {
    Name = "${var.name}-RDS-Subnet-Group"
  }
}


resource "aws_db_instance" "postgres" {
  identifier             = var.name
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
  multi_az               = false
  
  tags = {
    Name = var.name
  }
}
