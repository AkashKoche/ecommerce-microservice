output "vpc_id" {
  description = "The ID of the main VPC"
  value       = module.vpc.vpc_id
}

output "db_address" {
  description = "The endpoint address of the PostgreSQL database"
  value       = module.rds.db_address
}

output "redis_address" {
  description = "The endpoint address of the Redis cluster"
  value       = module.elasticache.redis_address
}

output "public_subnet_ids" {
  description = "List of Public Subnet IDs"
  value       = module.vpc.public_subnet_ids
}
