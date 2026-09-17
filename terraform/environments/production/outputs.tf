output "vpc_id" {
  value = module.network.vpc_id
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_endpoint" {
  value = module.eks.endpoint
}

output "eks_oidc_issuer" {
  value = module.eks.oidc_issuer
}

output "eks_node_group_name" {
  value = module.eks.node_group_name
}

output "node_security_group" {
  value = module.security.node_security_group_id
}

output "alb_security_group_id" {
  value = module.security.alb_security_group_id
}

output "backend_ecr_url" {
  value = module.ecr.backend_repository_url
}

output "frontend_ecr_url" {
  value = module.ecr.frontend_repository_url
}

output "aws_load_balancer_controller_role_arn" {
  value = module.load_balancer_controller.role_arn
}

output "database_endpoint" {
  value = try(module.database[0].endpoint, null)
}

output "app_secret_arn" {
  value = try(module.secrets[0].secret_arn, null)
}

output "acm_certificate_arn" {
  value = module.acm.certificate_arn
}