provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "FarmDirect"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Repository  = "DevOps-Realtime-Projects"
    }
  }
}