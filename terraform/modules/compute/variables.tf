variable "name" {
  description = "A unique prefix/name for the Compute resources (ALB,ASG,etc.)"
  type        = string
}

variable "region" {
  description = "The AWS region where the resources are being deployed."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the compute resources will be deployed."
  type        = string
}

variable "public_subnet_ids" {
  description = "List of Public Subnet IDs for the Application Load Balancer."
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of Private Subnet IDs for the Auto Scaling Group and EC2 instances."
  type        = list(string)
}

variable "app_security_group_id" {
  description = "The Security Group ID to assign to the EC2 instances."
  type        = string
}

variable "instance_profile_name" {
  description = "The name of the IAM Instance Profile for the EC2 instances."
  type        = string
}

variable "ecr_registry_url" {
  description = "The full URL of the ECR registry (e.g., 123456789012.dkr.ecr.us-east-1.amazonaws.com)."
  type        = string
}
