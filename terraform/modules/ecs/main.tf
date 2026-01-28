# =========================
# Locals for Naming and Tags
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
# ECS Cluster
# =========================
resource "aws_ecs_cluster" "main" {
  name = "${local.name}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled" # Good for New Relic infrastructure visibility
  }

  tags = merge({ Name = "${local.name}-cluster" }, local.common_tags)
}

# =========================
# CloudWatch Log Group
# =========================
# Requirement: Minimum 7-day retention
resource "aws_cloudwatch_log_group" "app_logs" {
  name              = "/ecs/${local.name}"
  retention_in_days = 7

  tags = local.common_tags
}

# =========================
# Task Definition
# =========================
resource "aws_ecs_task_definition" "main" {
  family                   = "${local.name}-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "app"
      image     = var.image
      essential = true

      portMappings = [
        {
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]

      # Requirement Step 4: New Relic Integration
      environment = [
        {
          name  = "NEW_RELIC_APP_NAME"
          value = "${var.project_name}-${var.stage}"
        },
        {
          name  = "NEW_RELIC_DISTRIBUTED_TRACING_ENABLED"
          value = "true"
        },
        {
          name  = "NEW_RELIC_LOG_LEVEL"
          value = "info"
        }
      ]

      # Best Practice: Pull sensitive License Key from Secrets Manager or SSM
      secrets = [
        {
          name      = "NEW_RELIC_LICENSE_KEY"
          valueFrom = var.newrelic_secret_arn
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.app_logs.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = local.common_tags
}

# =========================
# ECS Service
# =========================
resource "aws_ecs_service" "main" {
  name            = "${local.name}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  # Requirement: Deployment configuration
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.ecs_tasks.id] # Fixed below
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "app"
    container_port   = var.container_port
  }

  lifecycle {
    ignore_changes = [desired_count]
  }

  tags = local.common_tags
}

# =====================================================
# Security Groups (Correctly Scoped)
# =====================================================

# Requirement: ECS service security group allowing traffic from ALB only
resource "aws_security_group" "ecs_tasks" {
  name        = "${local.name}-ecs-tasks-sg"
  description = "allow inbound access from the ALB only"
  vpc_id      = var.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = var.container_port
    to_port         = var.container_port
    security_groups = [var.alb_security_group_id] # Source is the ALB SG
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({ Name = "${local.name}-ecs-tasks-sg" }, local.common_tags)
}