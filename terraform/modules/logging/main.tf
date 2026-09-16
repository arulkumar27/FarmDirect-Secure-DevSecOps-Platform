data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "alb_logs" {
  bucket = "farmdirect-${var.environment}-alb-logs-${data.aws_caller_identity.current.account_id}"

  # This bucket is the final audit-log destination.
  # S3 access logging is intentionally not enabled here because AWS recommends
  # not logging the destination bucket itself; it can cause recursive log delivery.

  tags = {
    Name        = "farmdirect-${var.environment}-alb-logs"
    Environment = var.environment
    Project     = "FarmDirect"
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket_public_access_block" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id

  rule {
    id     = "delete-old-alb-logs"
    status = "Enabled"

    filter {}

    expiration {
      days = 30
    }
  }
}

resource "aws_s3_bucket_policy" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id

  depends_on = [
    aws_s3_bucket_public_access_block.alb_logs,
    aws_s3_bucket_ownership_controls.alb_logs
  ]

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "AllowALBLogDelivery"
        Effect = "Allow"

        Principal = {
          Service = "logdelivery.elasticloadbalancing.amazonaws.com"
        }

        Action = "s3:PutObject"

        Resource = "${aws_s3_bucket.alb_logs.arn}/alb/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
      },
      {
        Sid    = "AllowALBLogBucketCheck"
        Effect = "Allow"

        Principal = {
          Service = "logdelivery.elasticloadbalancing.amazonaws.com"
        }

        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.alb_logs.arn
      },
      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"

        Resource = [
          aws_s3_bucket.alb_logs.arn,
          "${aws_s3_bucket.alb_logs.arn}/*"
        ]

        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}