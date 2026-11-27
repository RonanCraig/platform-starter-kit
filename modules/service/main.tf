resource "aws_security_group" "alb" {
  name_prefix = "${var.name}-alb-"
  lifecycle { create_before_destroy = true }
  description = "Security group for ALB"
  vpc_id      = var.vpc_id
  tags = {
    Name = "${var.name}-alb-sg"
  }
}

resource "aws_security_group" "app" {
  name_prefix = "${var.name}-app-"
  lifecycle { create_before_destroy = true }
  description = "Security group for app"
  vpc_id      = var.vpc_id
  tags = {
    Name = "${var.name}-app-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_ingress" {
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
  security_group_id = aws_security_group.alb.id
}

resource "aws_vpc_security_group_egress_rule" "alb_egress" {
  from_port                    = var.app_port
  to_port                      = var.app_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.app.id
  security_group_id            = aws_security_group.alb.id
}

resource "aws_vpc_security_group_ingress_rule" "app_ingress" {
  from_port                    = var.app_port
  to_port                      = var.app_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.alb.id
  security_group_id            = aws_security_group.app.id
}

data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_launch_template" "this" {
  name_prefix   = "${var.name}-lt-"
  image_id      = data.aws_ssm_parameter.al2023.value
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.app.id]

  user_data = filebase64("${path.module}/user_data.sh")

  metadata_options {
    http_tokens = "required"
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.name}-instance"
    }
  }
}

resource "aws_autoscaling_group" "this" {
  name                = "${var.name}-asg"
  max_size            = var.max_size
  min_size            = var.min_size
  desired_capacity    = var.desired_capacity
  vpc_zone_identifier = var.private_subnet_ids
  launch_template {
    id      = aws_launch_template.this.id
    version = aws_launch_template.this.latest_version
  }
  health_check_type         = "ELB"
  health_check_grace_period = 120

  target_group_arns = [aws_lb_target_group.this.arn]

  # Scaling policies change desired capacity at runtime; don't let Terraform reset it on every apply.
  lifecycle {
    ignore_changes = [desired_capacity]
  }
}

resource "aws_autoscaling_policy" "cpu_policy" {
  name                   = "${var.name}-cpu-policy"
  autoscaling_group_name = aws_autoscaling_group.this.name
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
}

resource "aws_lb" "this" {
  name               = "${var.name}-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids
}

resource "aws_lb_target_group" "this" {
  name     = "${var.name}-tg"
  port     = var.app_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}
