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
# Used by ECS agent to:
# - Pull images from ECR
# - Write logs to CloudWatch
# - Fetch secrets from Secrets Manager
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

# Managed policy: ECR + CloudWatch Logs
resource "aws_iam_role_policy_attachment" "execution_base" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Inline policy: Secrets Manager access (REQUIRED for New Relic)
resource "aws_iam_role_policy" "execution_secrets_access" {
  name = "${local.name}-ecs-secrets-access"
  role = aws_iam_role.execution.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue"
        ],
        Resource = "*"
      }
    ]
  })
}

# =========================
# ECS Task Role (Application)
# =========================
# Used by the application INSIDE the container
# (S3, DynamoDB, etc. if needed)
# =========================

resource "aws_iam_role" "task" {
  name = "${local.name}-ecs-task-role"

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
    { Name = "${local.name}-ecs-task-role" },
    local.common_tags
  )
}

