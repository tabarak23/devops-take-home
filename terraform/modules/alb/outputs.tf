output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "target_group_arn" {
  description = "Target group ARN for ECS service"
  value       = aws_lb_target_group.main.arn
}
