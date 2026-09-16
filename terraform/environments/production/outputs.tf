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

output "frontend_ecr_repository" {
  value = module.ecr.frontend_repository_url
}

output "backend_ecr_repository" {
  value = module.ecr.backend_repository_url
}

output "alb_logs_bucket" {
  value = module.logging.alb_logs_bucket_name
}

output "application_domain" {
  value = var.domain_name
}

output "alb_dns_name" {
  value = module.load_balancer.alb_dns_name
}

output "frontend_target_group_arn" {
  value = module.load_balancer.frontend_target_group_arn
}

output "backend_target_group_arn" {
  value = module.load_balancer.backend_target_group_arn
}

output "ecs_cluster_name" {
  value = module.ecs.cluster_name
}

output "frontend_ecs_service" {
  value = module.ecs.frontend_service_name
}

output "backend_ecs_service" {
  value = module.ecs.backend_service_name
}

output "database_endpoint" {
  value     = module.database.database_endpoint
  sensitive = true
}