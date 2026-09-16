output "database_password_secret_arn" {
  value     = try(aws_secretsmanager_secret.database_password[0].arn, null)
  sensitive = true
}

output "jwt_secret_arn" {
  value     = try(aws_secretsmanager_secret.jwt[0].arn, null)
  sensitive = true
}