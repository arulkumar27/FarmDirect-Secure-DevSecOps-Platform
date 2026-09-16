resource "aws_ecr_repository" "backend" {
  name                 = "farmdirect-${var.environment}-backend"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "farmdirect-${var.environment}-backend"
    Environment = var.environment
    Project     = "FarmDirect"
  }
}

resource "aws_ecr_repository" "frontend" {
  name                 = "farmdirect-${var.environment}-frontend"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "farmdirect-${var.environment}-frontend"
    Environment = var.environment
    Project     = "FarmDirect"
  }
}