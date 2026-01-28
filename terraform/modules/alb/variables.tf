variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "stage" {
  description = "Deployment stage (dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the ALB is created"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for the ALB"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security group ID attached to the ALB"
  type        = string
}

variable "container_port" {
  description = "Port on which the application container listens"
  type        = number
  default     = 8080
}

variable "alb_listener_port" {
  description = "ALB listener port"
  type        = number
  default     = 80
}

variable "health_check_path" {
  description = "Health check path for the target group"
  type        = string
  default     = "/health"
}
