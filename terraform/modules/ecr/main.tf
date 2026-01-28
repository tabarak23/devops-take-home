resource "aws_ecr_repository" "main" {
  name = var.repository_name
  force_delete = true
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = var.common_tags
}
