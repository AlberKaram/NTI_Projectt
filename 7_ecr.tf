# ECR Repository
resource "aws_ecr_repository" "nti_repo" {
  name = "nti-app-repo"

  image_scanning_configuration {
    scan_on_push = true
  }

  image_tag_mutability = "MUTABLE"

  tags = {
    Name = "nti-ecr-repo"
  }
}