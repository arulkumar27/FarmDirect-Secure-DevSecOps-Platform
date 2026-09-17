resource "aws_cloudwatch_log_group" "eks" {
    name="/aws/eks/${var.name}/cluster"
    retention_in_days=7
    tags=var.tags
}
