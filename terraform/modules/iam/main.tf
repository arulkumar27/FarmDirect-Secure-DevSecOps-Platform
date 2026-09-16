resource "aws_iam_role" "application" {
  name = "farmdirect-${var.environment}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "ec2.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name        = "farmdirect-${var.environment}-ec2-role"
    Environment = var.environment
    Project     = "FarmDirect"
  }
}

resource "aws_iam_instance_profile" "application" {
  name = "farmdirect-${var.environment}-instance-profile"
  role = aws_iam_role.application.name
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.application.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ecr_pull" {
  role       = aws_iam_role.application.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.application.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}