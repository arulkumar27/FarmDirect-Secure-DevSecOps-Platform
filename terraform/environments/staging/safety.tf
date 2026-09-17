resource "terraform_data" "apply_gate" {
  lifecycle {
    precondition {
      condition     = var.allow_aws_apply
      error_message = "AWS apply is blocked. Set allow_aws_apply=true for an intentional apply."
    }
  }
}