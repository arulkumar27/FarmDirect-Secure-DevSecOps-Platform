output "backend_repository_url" {
  description = "ECR URL where Jenkins pushes the backend Docker image."
  value       = aws_ecr_repository.backend.repository_url
}

output "frontend_repository_url" {
  description = "ECR URL where Jenkins pushes the frontend Docker image."
  value       = aws_ecr_repository.frontend.repository_url
}