variable "project_name" {
  description = "Project name"
  type        = string
}

variable "stage" {
  description = "Deployment stage"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "image" {
  description = "Docker image to use"
  type        = string
}

variable "newrelic_secret_arn" {
  type        = string
  description = "ARN of New Relic license key secret"
}

