variable "name" {
  description = "The identifier for the RDS instance and related resources."
  type        = string
}

variable "db_password" {
  description = "The master password for the database."
  type        = string
  sensitive   = true
}

variable "vpc_id" {
  description = "The ID of the VPC to deploy the database into."
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the DB Subnet Group."
  type        = list(string)
}

variable "app_security_group_id" {
  description = "The Security Group ID of the application servers that need to access the database."
  type        = string
}
