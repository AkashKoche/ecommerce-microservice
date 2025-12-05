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


module "vpc" {
  source  = "./modules/vpc"

  name                   = "ecommerce"
  vpc_cidr               = "10.0.0.0/16"
  public_subnet_cidrs    = ["10.0.1.0/24"]
  private_subnet_cidrs   = var.private_subnet_cidrs
  availability_zones     = data.aws_availability_zones.available.names
}


module "rds" {
  source  = "./modules/rds"

  name                = "ecommerce-postgres"
  db_password         = var.db_password
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  app_security_group_id = module.vpc.ec2_sg_id 
}


module "elasticache" {
  source = "./modules/elasticache"
  
  name                = "ecommerce-redis"
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  app_security_group_id = module.vpc.ec2_sg_id 
}


data "aws_availability_zones" "available" {
  state = "available"
}
