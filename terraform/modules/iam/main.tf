resource "aws_iam_role" "ec2_profile_role" {
  name_prefix = "ec2-app-role-"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principle = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecr_readonly" {
  role = aws_iam_role.ec2_profile_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "main" {
  name = "ec2-app-profile"
  role = aws_iam_role.ec2_profile_role.name
}
