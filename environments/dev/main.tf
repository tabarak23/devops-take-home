# =========================
# VPC
# =========================

module "vpc" {
  source = "../../terraform/modules/vpc"

  project_name = var.project_name
  stage        = var.stage
  vpc_cidr     = var.vpc_cidr
}

# =========================
# Security Groups
# =========================

resource "aws_security_group" "alb" {
  name   = "${var.project_name}-${var.stage}-alb-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs" {
  name   = "${var.project_name}-${var.stage}-ecs-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# =========================
# IAM
# =========================

module "iam" {
  source = "../../terraform/modules/iam"

  project_name = var.project_name
  stage        = var.stage
}

# =========================
# Logs
# =========================

module "logs" {
  source = "../../terraform/modules/logs"

  project_name = var.project_name
  stage        = var.stage
}

# =========================
# ALB
# =========================

module "alb" {
  source = "../../terraform/modules/alb"

  project_name          = var.project_name
  stage                 = var.stage
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  alb_security_group_id = aws_security_group.alb.id
}

# =========================
# ECS
# =========================

module "ecs" {
  source = "../../terraform/modules/ecs"

  project_name           = var.project_name
  stage                  = var.stage
  aws_region             = var.aws_region
  image                  = var.image
  execution_role_arn     = module.iam.ecs_execution_role_arn
  task_role_arn          = module.iam.ecs_task_role_arn
  log_group_name         = module.logs.log_group_name
  target_group_arn       = module.alb.target_group_arn
  private_subnet_ids     = module.vpc.private_subnet_ids
  vpc_id                 = module.vpc.vpc_id
  alb_security_group_id  = aws_security_group.alb.id
  newrelic_secret_arn    = var.newrelic_secret_arn

}

# =========================
# Autoscaling
# =========================

module "autoscaling" {
  source = "../../terraform/modules/autoscaling"

  project_name = var.project_name
  stage        = var.stage
  cluster_name = module.ecs.cluster_name
  service_name = module.ecs.service_name
}


# =========================
# ECR
# =========================

module "ecr" {
  source = "../../terraform/modules/ecr"

  repository_name = "${var.project_name}-${var.stage}"
  common_tags = {
    Project     = var.project_name
    Environment = var.stage
    ManagedBy   = "Terraform"
  }
}
