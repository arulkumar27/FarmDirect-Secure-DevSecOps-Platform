output "vpc_id" {
  description = "FarmDirect VPC ID."
  value       = aws_vpc.farmdirect.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs for ALB."
  value       = aws_subnet.public[*].id
}

output "private_app_subnet_ids" {
  description = "Private application subnet IDs for backend compute."
  value       = aws_subnet.private_app[*].id
}

output "private_database_subnet_ids" {
  description = "Private database subnet IDs for RDS."
  value       = aws_subnet.private_database[*].id
}

output "private_app_route_table_id" {
  description = "Route table ID used by private application subnets."
  value       = aws_route_table.private_app.id
}