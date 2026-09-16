output "vpc_id" {
  value = module.network.vpc_id
}

output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}

output "private_app_subnet_ids" {
  value = module.network.private_app_subnet_ids
}

output "private_database_subnet_ids" {
  value = module.network.private_database_subnet_ids
}

output "backend_ecr_repository" {
  value = module.ecr.backend_repository_url
}

output "frontend_ecr_repository" {
  value = module.ecr.frontend_repository_url
}

output "application_domain" {
  value = module.dns.application_domain
}

output "alb_dns_name" {
  value = module.load_balancer.alb_dns_name
}

output "database_endpoint" {
  value     = module.database.database_endpoint
  sensitive = true
}