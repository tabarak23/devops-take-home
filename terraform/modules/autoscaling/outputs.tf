output "autoscaling_target_resource_id" {
  description = "Auto Scaling target resource ID"
  value       = aws_appautoscaling_target.main.resource_id
}

output "autoscaling_policy_name" {
  description = "Auto Scaling policy name"
  value       = aws_appautoscaling_policy.main.name
}
