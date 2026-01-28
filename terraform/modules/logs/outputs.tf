output "log_group_name" {
  description = "CloudWatch log group name for ECS"
  value       = aws_cloudwatch_log_group.main.name
}
