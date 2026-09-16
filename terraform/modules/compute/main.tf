data "aws_ssm_parameter" "amazon_linux_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_launch_template" "farmdirect" {
  count = var.create_compute ? 1 : 0

  name_prefix   = "farmdirect-${var.environment}-"
  image_id      = data.aws_ssm_parameter.amazon_linux_ami.value
  instance_type = var.instance_type

  iam_instance_profile {
    name = var.instance_profile_name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.application_security_group_id]
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = "farmdirect-${var.environment}-app"
      Environment = var.environment
      Project     = "FarmDirect"
      ManagedBy   = "Terraform"
    }
  }
}

resource "aws_autoscaling_group" "farmdirect" {
  count = var.create_compute ? 1 : 0

  name                      = "farmdirect-${var.environment}-asg"
  min_size                  = var.min_instances
  max_size                  = var.max_instances
  desired_capacity          = var.desired_instances
  vpc_zone_identifier       = var.private_app_subnet_ids
  health_check_type         = "ELB"
  health_check_grace_period = 180
  target_group_arns         = var.target_group_arn == null ? [] : [var.target_group_arn]

  launch_template {
    id      = aws_launch_template.farmdirect[0].id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "farmdirect-${var.environment}-app"
    propagate_at_launch = true
  }
}