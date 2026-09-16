output "database_endpoint" {
  value     = try(aws_db_instance.farmdirect[0].address, null)
  sensitive = true
}

output "database_port" {
  value = try(aws_db_instance.farmdirect[0].port, null)
}