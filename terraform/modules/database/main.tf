resource "aws_db_subnet_group" "this" {
    name="${var.name}-db"
    subnet_ids=var.subnet_ids
    tags=var.tags
    }

resource "aws_db_instance" "this" {
    identifier="${var.name}-postgres"
    engine="postgres"
    engine_version=var.engine_version
    instance_class=var.instance_class
    allocated_storage=var.storage
    max_allocated_storage=50
    storage_type="gp3"
    storage_encrypted=true
    db_name=var.database_name
    username=var.database_username
    password=var.database_password
    port=5432
    db_subnet_group_name=aws_db_subnet_group.this.name
    vpc_security_group_ids=[var.security_group_id]
    publicly_accessible=false
    multi_az=false
    backup_retention_period=1
    deletion_protection=false
    skip_final_snapshot=true
    apply_immediately=true
    tags=var.tags
    }
