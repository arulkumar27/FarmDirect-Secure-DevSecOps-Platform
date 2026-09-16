output "autoscaling_group_name" {
  value = try(aws_autoscaling_group.farmdirect[0].name, null)
}