data "aws_region" "current" {}

resource "aws_vpc_endpoint" "s3" {
  count = var.create_vpc_endpoints ? 1 : 0

  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [var.private_app_route_table_id]

  tags = {
    Name        = "farmdirect-${var.environment}-s3-endpoint"
    Environment = var.environment
    Project     = "FarmDirect"
    ManagedBy   = "Terraform"
  }
}

resource "aws_security_group" "interface_endpoints" {
  count = var.create_vpc_endpoints && var.enable_interface_endpoints ? 1 : 0

  name        = "farmdirect-${var.environment}-endpoints-sg"
  description = "Allows FarmDirect ECS tasks to reach AWS interface endpoints."
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTPS from frontend ECS tasks"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [var.frontend_security_group_id]
  }

  ingress {
    description     = "HTTPS from backend ECS tasks"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [var.backend_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "farmdirect-${var.environment}-endpoints-sg"
    Environment = var.environment
    Project     = "FarmDirect"
    ManagedBy   = "Terraform"
  }
}

resource "aws_vpc_endpoint" "interface" {
  for_each = var.create_vpc_endpoints && var.enable_interface_endpoints ? toset([
    "ecr.api",
    "ecr.dkr",
    "logs",
    "secretsmanager",
    "ssmmessages"
  ]) : toset([])

  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.region}.${each.value}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_app_subnet_ids
  security_group_ids  = [aws_security_group.interface_endpoints[0].id]
  private_dns_enabled = true

  tags = {
    Name        = "farmdirect-${var.environment}-${replace(each.value, ".", "-")}-endpoint"
    Environment = var.environment
    Project     = "FarmDirect"
    ManagedBy   = "Terraform"
  }
}