output "instance_profile_name" {
  description = "Name of the IAM Instance Profile for EC2."
  value       = aws_iam_instance_profile.main.name
}
