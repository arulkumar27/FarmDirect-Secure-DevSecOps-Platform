resource "aws_secretsmanager_secret" "app" {
    name="${var.name}/app"
    tags=var.tags
}

resource "aws_secretsmanager_secret_version" "app" {
    secret_id=aws_secretsmanager_secret.app.id
    secret_string=jsonencode({
        database_username=var.database_username,
        database_password=var.database_password,
        database_name=var.database_name,
        jwt_secret=var.jwt_secret
    })
}
