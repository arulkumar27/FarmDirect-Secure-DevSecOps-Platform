resource "aws_security_group" "alb" {
  name        = "farmdirect-${var.environment}-alb-sg"
  description = "Allows public HTTP and HTTPS traffic to the FarmDirect ALB."
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP redirect to HTTPS"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Public HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "ALB can reach application tasks"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "farmdirect-${var.environment}-alb-sg"
    Environment = var.environment
    Project     = "FarmDirect"
  }
}

resource "aws_security_group" "frontend" {
  name        = "farmdirect-${var.environment}-frontend-sg"
  description = "Allows only ALB traffic to FarmDirect frontend ECS tasks."
  vpc_id      = var.vpc_id

  ingress {
    description     = "Frontend HTTP from ALB only"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Required outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "farmdirect-${var.environment}-frontend-sg"
    Environment = var.environment
    Project     = "FarmDirect"
  }
}

resource "aws_security_group" "backend" {
  name        = "farmdirect-${var.environment}-backend-sg"
  description = "Allows only ALB traffic to FarmDirect backend ECS tasks."
  vpc_id      = var.vpc_id

  ingress {
    description     = "Backend API traffic from ALB only"
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Backend can reach RDS and AWS services"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "farmdirect-${var.environment}-backend-sg"
    Environment = var.environment
    Project     = "FarmDirect"
  }
}

resource "aws_security_group" "database" {
  name        = "farmdirect-${var.environment}-db-sg"
  description = "Allows PostgreSQL only from FarmDirect backend ECS tasks."
  vpc_id      = var.vpc_id

  ingress {
    description     = "PostgreSQL from backend only"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.backend.id]
  }

  tags = {
    Name        = "farmdirect-${var.environment}-db-sg"
    Environment = var.environment
    Project     = "FarmDirect"
  }
}