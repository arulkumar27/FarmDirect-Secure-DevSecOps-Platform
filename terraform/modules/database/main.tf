resource "aws_db_subnet_group" "farmdirect" {
  count = var.create_database ? 1 : 0

  name       = "farmdirect-${var.environment}-db-subnet-group"
  subnet_ids = var.private_database_subnet_ids

  tags = {
    Name        = "farmdirect-${var.environment}-db-subnet-group"
    Environment = var.environment
    Project     = "FarmDirect"
  }
}

resource "aws_db_instance" "farmdirect" {
  count = var.create_database ? 1 : 0

  identifier        = "farmdirect-${var.environment}-postgres"
  engine            = "postgres"
  engine_version    = "16"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = var.database_name
  username = var.database_username
  password = var.database_password
  port     = 5432

  db_subnet_group_name   = aws_db_subnet_group.farmdirect[0].name
  vpc_security_group_ids = [var.database_security_group_id]
  publicly_accessible    = false
  multi_az               = false

  backup_retention_period = 1
  deletion_protection     = var.deletion_protection
  skip_final_snapshot     = var.skip_final_snapshot

  final_snapshot_identifier = var.skip_final_snapshot ? null : "farmdirect-${var.environment}-final-snapshot"

  auto_minor_version_upgrade = true
  apply_immediately          = true

  tags = {
    Name        = "farmdirect-${var.environment}-postgres"
    Environment = var.environment
    Project     = "FarmDirect"
    ManagedBy   = "Terraform"
  }
}