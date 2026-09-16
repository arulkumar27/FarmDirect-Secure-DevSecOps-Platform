resource "aws_secretsmanager_secret" "database_password" {
  count = var.create_secrets ? 1 : 0

  name                    = "farmdirect/${var.environment}/database-password"
  recovery_window_in_days = 7

  tags = {
    Name        = "farmdirect-${var.environment}-database-password"
    Environment = var.environment
    Project     = "FarmDirect"
    ManagedBy   = "Terraform"
  }
}

resource "aws_secretsmanager_secret_version" "database_password" {
  count = var.create_secrets ? 1 : 0

  secret_id     = aws_secretsmanager_secret.database_password[0].id
  secret_string = var.database_password

  lifecycle {
    precondition {
      condition     = var.database_password != ""
      error_message = "A database password is required when create_secrets is true."
    }
  }
}

resource "aws_secretsmanager_secret" "jwt" {
  count = var.create_secrets ? 1 : 0

  name                    = "farmdirect/${var.environment}/jwt-secret"
  recovery_window_in_days = 7

  tags = {
    Name        = "farmdirect-${var.environment}-jwt-secret"
    Environment = var.environment
    Project     = "FarmDirect"
    ManagedBy   = "Terraform"
  }
}

resource "aws_secretsmanager_secret_version" "jwt" {
  count = var.create_secrets ? 1 : 0

  secret_id     = aws_secretsmanager_secret.jwt[0].id
  secret_string = var.jwt_secret

  lifecycle {
    precondition {
      condition     = var.jwt_secret != ""
      error_message = "A JWT secret is required when create_secrets is true."
    }
  }
}