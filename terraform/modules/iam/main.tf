# =========================
# IAM Module for ECS Tasks
# =========================
# Defines execution and task roles for ECS Fargate

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
# ECS Task Execution Role
# =========================

resource "aws_iam_role" "execution" {
  name = "${local.name}-ecs-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    { Name = "${local.name}-ecs-exec-role" },
    local.common_tags
  )
}

resource "aws_iam_role_policy_attachment" "execution" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# =========================
# ECS Task Role (Application)
# =========================

resource "aws_iam_role" "task" {
  name = "${local.name}-ecs-task-role"

  assume_role_policy = aws_iam_role.execution.assume_role_policy

  tags = merge(
    { Name = "${local.name}-ecs-task-role" },
    local.common_tags
  )
}
