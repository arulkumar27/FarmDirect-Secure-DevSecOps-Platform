output "cluster_name" {
  value = try(aws_ecs_cluster.farmdirect[0].name, null)
}

output "cluster_arn" {
  value = try(aws_ecs_cluster.farmdirect[0].arn, null)
}

output "frontend_service_name" {
  value = try(aws_ecs_service.frontend[0].name, null)
}

output "backend_service_name" {
  value = try(aws_ecs_service.backend[0].name, null)
}