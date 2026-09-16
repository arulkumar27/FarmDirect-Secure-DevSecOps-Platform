module "network" {
  source = "../../modules/network"

  environment                   = var.environment
  vpc_cidr                      = var.vpc_cidr
  availability_zones            = var.availability_zones
  public_subnet_cidrs           = var.public_subnet_cidrs
  private_app_subnet_cidrs      = var.private_app_subnet_cidrs
  private_database_subnet_cidrs = var.private_database_subnet_cidrs

  enable_nat_gateway = var.enable_nat_gateway
}

module "security" {
  source = "../../modules/security"

  environment = var.environment
  vpc_id      = module.network.vpc_id
}

module "endpoints" {
  source = "../../modules/endpoints"

  environment                = var.environment
  vpc_id                     = module.network.vpc_id
  private_app_subnet_ids     = module.network.private_app_subnet_ids
  private_app_route_table_id = module.network.private_app_route_table_id
  frontend_security_group_id = module.security.frontend_security_group_id
  backend_security_group_id  = module.security.backend_security_group_id
  create_vpc_endpoints       = var.create_vpc_endpoints
  enable_interface_endpoints = var.enable_interface_endpoints
}

module "ecr" {
  source = "../../modules/ecr"

  environment = var.environment
}

module "logging" {
  source = "../../modules/logging"

  environment = var.environment
}

module "secrets" {
  source = "../../modules/secrets"

  environment       = var.environment
  database_password = var.database_password
  jwt_secret        = var.jwt_secret
  create_secrets    = var.create_secrets
}

module "database" {
  source = "../../modules/database"

  environment                 = var.environment
  private_database_subnet_ids = module.network.private_database_subnet_ids
  database_security_group_id  = module.security.database_security_group_id
  database_name               = var.database_name
  database_username           = var.database_username
  database_password           = var.database_password
  create_database             = var.create_database
  deletion_protection         = var.database_deletion_protection
  skip_final_snapshot         = var.database_skip_final_snapshot
}

module "acm" {
  source = "../../modules/acm"

  environment            = var.environment
  route53_zone_id        = var.route53_zone_id
  domain_name            = var.domain_name
  create_acm_certificate = var.create_acm_certificate
}

module "load_balancer" {
  source = "../../modules/load-balancer"

  environment                 = var.environment
  vpc_id                      = module.network.vpc_id
  public_subnet_ids           = module.network.public_subnet_ids
  alb_security_group_id       = module.security.alb_security_group_id
  certificate_arn             = coalesce(module.acm.certificate_arn, var.certificate_arn, "not-configured")
  alb_access_logs_bucket_name = module.logging.alb_logs_bucket_name
  create_alb                  = var.create_alb
  enable_deletion_protection  = var.alb_deletion_protection
}

module "ecs" {
  source     = "../../modules/ecs"
  depends_on = [module.endpoints]

  environment                = var.environment
  private_app_subnet_ids     = module.network.private_app_subnet_ids
  frontend_security_group_id = module.security.frontend_security_group_id
  backend_security_group_id  = module.security.backend_security_group_id

  frontend_target_group_arn = module.load_balancer.frontend_target_group_arn
  backend_target_group_arn  = module.load_balancer.backend_target_group_arn

  frontend_image = "${module.ecr.frontend_repository_url}:${var.frontend_image_tag}"
  backend_image  = "${module.ecr.backend_repository_url}:${var.backend_image_tag}"

  database_host                = module.database.database_endpoint
  database_name                = var.database_name
  database_username            = var.database_username
  database_password_secret_arn = module.secrets.database_password_secret_arn
  jwt_secret_arn               = module.secrets.jwt_secret_arn
  application_domain           = var.domain_name

  frontend_desired_count = var.frontend_desired_count
  backend_desired_count  = var.backend_desired_count
  backend_min_count      = var.backend_min_count
  backend_max_count      = var.backend_max_count
  create_ecs             = var.create_ecs
}

module "dns" {
  source = "../../modules/dns"

  environment           = var.environment
  route53_zone_id       = var.route53_zone_id
  domain_name           = var.domain_name
  alb_dns_name          = module.load_balancer.alb_dns_name
  alb_zone_id           = module.load_balancer.alb_zone_id
  create_route53_record = var.create_route53_record
}