# =========================
# CloudWatch Logs for ECS Application
# =========================


locals {
  name = "${var.project_name}-${var.stage}"

  common_tags = {
    Project     = var.project_name
    Environment = var.stage
    ManagedBy   = "Terraform"
  }
}


resource "aws_cloudwatch_log_group" "main" {
  name              = "/aws/ecs/${local.name}"
  retention_in_days = var.log_retention_days

  tags = merge(
    { Name = "${local.name}-ecs-logs" },
    local.common_tags
  )
}
