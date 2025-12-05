variable "name" {
  description = "The cluster ID and identifier for related resources."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC to deploy the cluster into."
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the Cache Subnet Group."
  type        = list(string)
}

variable "app_security_group_id" {
  description = "The Security Group ID of the application servers that need to access the Redis cache."
  type        = string
}
