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

module "ecr" {
  source = "../../modules/ecr"

  environment = var.environment
}

module "iam" {
  source = "../../modules/iam"

  environment = var.environment
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

  environment           = var.environment
  vpc_id                = module.network.vpc_id
  public_subnet_ids     = module.network.public_subnet_ids
  alb_security_group_id = module.security.alb_security_group_id
  certificate_arn       = module.acm.certificate_arn != null ? module.acm.certificate_arn : var.certificate_arn
  create_alb            = var.create_alb
}

module "compute" {
  source = "../../modules/compute"

  environment                   = var.environment
  private_app_subnet_ids        = module.network.private_app_subnet_ids
  application_security_group_id = module.security.application_security_group_id
  instance_profile_name         = module.iam.instance_profile_name
  target_group_arn              = module.load_balancer.frontend_target_group_arn
  instance_type                 = var.instance_type
  min_instances                 = var.min_instances
  desired_instances             = var.desired_instances
  max_instances                 = var.max_instances
  create_compute                = var.create_compute
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

module "dns" {
  source = "../../modules/dns"

  environment           = var.environment
  route53_zone_id       = var.route53_zone_id
  domain_name           = var.domain_name
  alb_dns_name          = module.load_balancer.alb_dns_name
  alb_zone_id           = module.load_balancer.alb_zone_id
  create_route53_record = var.create_route53_record
}