data "aws_region" "current" {}

resource "aws_cloudwatch_log_group" "frontend" {
  count = var.create_ecs ? 1 : 0

  name              = "/ecs/farmdirect-${var.environment}-frontend"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "backend" {
  count = var.create_ecs ? 1 : 0

  name              = "/ecs/farmdirect-${var.environment}-backend"
  retention_in_days = 30
}

resource "aws_iam_role" "task_execution" {
  count = var.create_ecs ? 1 : 0

  name = "farmdirect-${var.environment}-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role" "task" {
  count = var.create_ecs ? 1 : 0

  name = "farmdirect-${var.environment}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "ecs_exec" {
  count = var.create_ecs ? 1 : 0

  name = "farmdirect-${var.environment}-ecs-exec"
  role = aws_iam_role.task[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ssmmessages:CreateControlChannel",
        "ssmmessages:CreateDataChannel",
        "ssmmessages:OpenControlChannel",
        "ssmmessages:OpenDataChannel"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "task_execution" {
  count = var.create_ecs ? 1 : 0

  role       = aws_iam_role.task_execution[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "read_secrets" {
  count = var.create_ecs ? 1 : 0

  name = "farmdirect-${var.environment}-read-secrets"
  role = aws_iam_role.task_execution[0].id

  lifecycle {
    precondition {
      condition = (
        var.database_password_secret_arn != "" &&
        var.jwt_secret_arn != ""
      )

      error_message = "Both Secrets Manager ARNs are required before ECS can be created."
    }
  }

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Action = [
        "secretsmanager:GetSecretValue"
      ]

      Resource = [
        var.database_password_secret_arn,
        var.jwt_secret_arn
      ]
    }]
  })
}

resource "aws_ecs_cluster" "farmdirect" {
  count = var.create_ecs ? 1 : 0

  name = "farmdirect-${var.environment}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "frontend" {
  count = var.create_ecs ? 1 : 0

  family                   = "farmdirect-${var.environment}-frontend"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.task_execution[0].arn
  task_role_arn            = aws_iam_role.task[0].arn

  lifecycle {
    precondition {
      condition     = var.frontend_image != ""
      error_message = "A frontend ECR image URI is required before ECS can be created."
    }
  }

  container_definitions = jsonencode([
    {
      name      = "frontend"
      image     = var.frontend_image
      essential = true

      portMappings = [{
        containerPort = 8080
        protocol      = "tcp"
      }]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          awslogs-group         = aws_cloudwatch_log_group.frontend[0].name
          awslogs-region        = data.aws_region.current.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "backend" {
  count = var.create_ecs ? 1 : 0

  family                   = "farmdirect-${var.environment}-backend"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.task_execution[0].arn
  task_role_arn            = aws_iam_role.task[0].arn

  lifecycle {
    precondition {
      condition = (
        var.backend_image != "" &&
        var.database_host != "" &&
        var.database_password_secret_arn != "" &&
        var.jwt_secret_arn != ""
      )

      error_message = "Backend image, database host, DB secret ARN, and JWT secret ARN are required before ECS can be created."
    }
  }

  container_definitions = jsonencode([
    {
      name      = "backend"
      image     = var.backend_image
      essential = true

      portMappings = [{
        containerPort = 5000
        protocol      = "tcp"
      }]

      environment = [
        {
          name  = "PORT"
          value = "5000"
        },
        {
          name  = "CLIENT_ORIGIN"
          value = "https://${var.application_domain}"
        },
        {
          name  = "DB_HOST"
          value = var.database_host
        },
        {
          name  = "DB_PORT"
          value = "5432"
        },
        {
          name  = "DB_NAME"
          value = var.database_name
        },
        {
          name  = "DB_USER"
          value = var.database_username
        },
        {
          name  = "DB_SSL"
          value = "true"
        }
      ]

      secrets = [
        {
          name      = "DB_PASSWORD"
          valueFrom = var.database_password_secret_arn
        },
        {
          name      = "JWT_SECRET"
          valueFrom = var.jwt_secret_arn
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          awslogs-group         = aws_cloudwatch_log_group.backend[0].name
          awslogs-region        = data.aws_region.current.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "frontend" {
  count = var.create_ecs ? 1 : 0

  name                              = "farmdirect-${var.environment}-frontend"
  cluster                           = aws_ecs_cluster.farmdirect[0].id
  task_definition                   = aws_ecs_task_definition.frontend[0].arn
  desired_count                     = var.frontend_desired_count
  launch_type                       = "FARGATE"
  health_check_grace_period_seconds = 90
  enable_execute_command            = true
  propagate_tags                    = "SERVICE"

  network_configuration {
    subnets          = var.private_app_subnet_ids
    security_groups  = [var.frontend_security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.frontend_target_group_arn
    container_name   = "frontend"
    container_port   = 8080
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }
}

resource "aws_ecs_service" "backend" {
  count = var.create_ecs ? 1 : 0

  name                              = "farmdirect-${var.environment}-backend"
  cluster                           = aws_ecs_cluster.farmdirect[0].id
  task_definition                   = aws_ecs_task_definition.backend[0].arn
  desired_count                     = var.backend_desired_count
  launch_type                       = "FARGATE"
  health_check_grace_period_seconds = 90
  enable_execute_command            = true
  propagate_tags                    = "SERVICE"

  network_configuration {
    subnets          = var.private_app_subnet_ids
    security_groups  = [var.backend_security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.backend_target_group_arn
    container_name   = "backend"
    container_port   = 5000
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }
}

resource "aws_appautoscaling_target" "backend" {
  count = var.create_ecs ? 1 : 0

  max_capacity       = var.backend_max_count
  min_capacity       = var.backend_min_count
  resource_id        = "service/${aws_ecs_cluster.farmdirect[0].name}/${aws_ecs_service.backend[0].name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "backend_cpu" {
  count = var.create_ecs ? 1 : 0

  name               = "farmdirect-${var.environment}-backend-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.backend[0].resource_id
  scalable_dimension = aws_appautoscaling_target.backend[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.backend[0].service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 70

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}