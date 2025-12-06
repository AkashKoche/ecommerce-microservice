resource "aws_security_group" "alb_sg" {
  name        = "${var.name}-alb-sg"
  vpc_id      = var.vpc_id
  description = "Allow HTTP access to the ALB"


  ingress {
    from_port      = 80
    to_port        = 80
    protocol       = "tcp"
    cidr_blocks    = ["0.0.0.0/0"]
  }

  egress {
    from_port      = 0
    to_port        = 0
    protocol       = "-1"
    cidr_blocks    = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "main" {
  name             = "${var.name}-alb"
  internal         = false
  load_balancer_type = "application"
  security_groups   = [aws_security_group.alb_sg.id]
  subnets           = var.public_subnet_ids
}

resource "aws_lb_target_group" "api" {
  name         = "${var.name}-api-tg"
  port         = 8080
  protocol     = "HTTP"
  vpc_id       = var.vpc_id

  health_check {

    path              = "/health"
    protocol          = "HTTP"
    matcher           = "200"
    interval          = 30
    timeout           = 5
    healthy_threshold = 2
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type                 = "forward"
    target_group_arn     = aws_lb_target_group.api.arn
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/user_data.sh")
  vars = {
    AWS_REGION    = var.region
    ECR_REGISTRY  = var.ecr_registry_url
  }
}

resource "aws_launch_template" "main" {
  name_prefix   = "${var.name}-lt"
  image_id      = "ami-08b5b3a93ed654d19"
  instance_type = "t2.micro"

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.app_security_group_id]
  }

  iam_instance_profile {
    name = var.instance_profile_name
  }

  user_data = base64encode(data.template_file.user_data.rendered)
}

# Auto Scaling Group
resource "aws_autoscaling_group" "main" {
  name                      = "${var.name}-asg"
  vpc_zone_identifier       = var.private_subnet_ids
  desired_capacity          = 1
  max_size                  = 2
  min_size                  = 1
  health_check_type         = "ELB"
  target_group_arns         = [aws_lb_target_group.api.arn]

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }
}
