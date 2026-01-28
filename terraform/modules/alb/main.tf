# =========================
# Application Load Balancer
# =========================
# Public ALB for routing traffic to ECS services

# =========================
# Locals
# =========================

locals {
  name = "${var.project_name}-${var.stage}"

  common_tags = {
    Project     = var.project_name
    Environment = var.stage
    ManagedBy   = "Terraform"
  }
}

# =========================
# Load Balancer
# =========================

resource "aws_lb" "main" {
  name               = "${local.name}-alb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = merge(
    { Name = "${local.name}-alb" },
    local.common_tags
  )
}

# =========================
# Target Group
# =========================

resource "aws_lb_target_group" "main" {
  name        = "${local.name}-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = var.health_check_path
    matcher             = "200"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = merge(
    { Name = "${local.name}-tg" },
    local.common_tags
  )
}

# =========================
# Listener
# =========================

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = var.alb_listener_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}
