resource "aws_ecr_repository" "backend" {
    name="${var.name}/backend"
    image_tag_mutability="IMMUTABLE"
    image_scanning_configuration {scan_on_push=true}
    tags=var.tags
}

resource "aws_ecr_repository" "frontend" {
    name="${var.name}/frontend"
    image_tag_mutability="IMMUTABLE"
    image_scanning_configuration {scan_on_push=true}
    tags=var.tags
}
