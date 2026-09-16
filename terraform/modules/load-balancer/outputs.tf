output "alb_dns_name" {
  value = try(aws_lb.farmdirect[0].dns_name, null)
}

output "alb_zone_id" {
  value = try(aws_lb.farmdirect[0].zone_id, null)
}

output "frontend_target_group_arn" {
  value = try(aws_lb_target_group.frontend[0].arn, null)
}

output "backend_target_group_arn" {
  value = try(aws_lb_target_group.backend[0].arn, null)
}