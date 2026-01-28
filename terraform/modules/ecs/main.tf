# =========================
# ECS Module for Application
# =========================
# Creates ECS cluster, task definition, and Fargate service

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
# ECS Cluster
# =========================

resource "aws_ecs_cluster" "main" {
  name = "${local.name}-cluster"

  tags = merge(
    { Name = "${local.name}-cluster" },
    local.common_tags
  )
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
        }
      ]

      environment = [
        {
          name  = "NEW_RELIC_APP_NAME"
          value = "${var.project_name}-${var.stage}"
        },
        {
          name  = "NEW_RELIC_ENABLED"
          value = "true"
        }
      ]

      secrets = [
        {
          name      = "NEW_RELIC_LICENSE_KEY"
          valueFrom = var.newrelic_secret_arn
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = var.log_group_name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
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

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_security_group_id]
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

  tags = merge(
    { Name = "${local.name}-service" },
    local.common_tags
  )
}

