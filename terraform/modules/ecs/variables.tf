variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "stage" {
  description = "Deployment stage (dev, staging, prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS region for ECS resources"
  type        = string
}

variable "image" {
  description = "Docker image URI for the application"
  type        = string
}

variable "newrelic_secret_arn" {
  type        = string
  description = "ARN of New Relic license key secret"
}


variable "cpu" {
  description = "CPU units for the ECS task"
  type        = number
  default     = 512
}

variable "memory" {
  description = "Memory (MB) for the ECS task"
  type        = number
  default     = 1024
}

variable "desired_count" {
  description = "Desired number of ECS tasks"
  type        = number
  default     = 1
}

variable "container_port" {
  description = "Port exposed by the application container"
  type        = number
  default     = 8080
}

variable "execution_role_arn" {
  description = "IAM execution role ARN for ECS tasks"
  type        = string
}

variable "task_role_arn" {
  description = "IAM task role ARN for the application"
  type        = string
}

variable "log_group_name" {
  description = "CloudWatch log group name for ECS"
  type        = string
}

variable "target_group_arn" {
  description = "ALB target group ARN"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for ECS service"
  type        = list(string)
}



variable "vpc_id" {
  type        = string
  description = "The VPC ID where the security group will be created"
}

variable "alb_security_group_id" {
  type        = string
  description = "The security group ID of the Load Balancer"
}