output "instance_profile_name" {
  description = "Instance profile attached to FarmDirect EC2 application instances."
  value       = aws_iam_instance_profile.application.name
}

output "application_role_arn" {
  description = "IAM role ARN for FarmDirect application EC2 instances."
  value       = aws_iam_role.application.arn
}