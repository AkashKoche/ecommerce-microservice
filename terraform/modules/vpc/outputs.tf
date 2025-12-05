output "vpc_id" {
  description = "The ID of the main VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "List of Public Subnet IDs"
  value       = [for s in aws_subnet.public : s.id]
}

output "private_subnet_ids" {
  description = "List of Private Subnet IDs"
  value       = [for s in aws_subnet.private : s.id]
}

output "ec2_sg_id" {
  description = "The ID of the Security Group for EC2 instances"
  value       = aws_security_group.ec2_sg.id
}
