output "db_address" {
  description = "The endpoint address of the PostgreSQL database"
  value       = aws_db_instance.postgres.address
}

output "rds_sg_id" {
  description = "The ID of the Security Group for RDS"
  value       = aws_security_group.rds_sg.id
}
