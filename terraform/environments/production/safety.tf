resource "terraform_data" "aws_apply_safety_gate" {
  input = var.allow_aws_apply

  lifecycle {
    precondition {
      condition     = var.allow_aws_apply
      error_message = "AWS deployment safety lock is ON. Keep allow_aws_apply=false for validation. Set it to true only during the short, approved live demo."
    }
  }
}