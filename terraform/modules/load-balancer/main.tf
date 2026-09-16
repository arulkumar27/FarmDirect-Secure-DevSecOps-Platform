resource "aws_lb" "farmdirect" {
  count = var.create_alb ? 1 : 0

  name                       = "farmdirect-${var.environment}-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [var.alb_security_group_id]
  subnets                    = var.public_subnet_ids
  enable_deletion_protection = var.enable_deletion_protection
  drop_invalid_header_fields = true

  access_logs {
    bucket  = var.alb_access_logs_bucket_name
    prefix  = "alb"
    enabled = true
  }

  lifecycle {
    precondition {
      condition     = var.certificate_arn != ""
      error_message = "An ACM certificate ARN is required when create_alb is true."
    }

    precondition {
      condition     = var.alb_access_logs_bucket_name != ""
      error_message = "An encrypted S3 ALB logs bucket is required when create_alb is true."
    }
  }

  tags = {
    Name        = "farmdirect-${var.environment}-alb"
    Environment = var.environment
    Project     = "FarmDirect"
  }
}

resource "aws_lb_target_group" "frontend" {
  count = var.create_alb ? 1 : 0

  name        = "fd-${var.environment}-frontend-8080-tg"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  health_check {
    enabled             = true
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
  }

  tags = {
    Name        = "farmdirect-${var.environment}-frontend-tg"
    Environment = var.environment
    Project     = "FarmDirect"
  }
}

resource "aws_lb_target_group" "backend" {
  count = var.create_alb ? 1 : 0

  name        = "fd-${var.environment}-backend-tg"
  port        = 5000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    path                = "/api/health"
    protocol            = "HTTP"
    matcher             = "200"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
  }

  tags = {
    Name        = "farmdirect-${var.environment}-backend-tg"
    Environment = var.environment
    Project     = "FarmDirect"
  }
}

resource "aws_lb_listener" "http_redirect" {
  count = var.create_alb ? 1 : 0

  load_balancer_arn = aws_lb.farmdirect[0].arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  count = var.create_alb ? 1 : 0

  load_balancer_arn = aws_lb.farmdirect[0].arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend[0].arn
  }
}

resource "aws_lb_listener_rule" "backend_api" {
  count = var.create_alb ? 1 : 0

  listener_arn = aws_lb_listener.https[0].arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend[0].arn
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}