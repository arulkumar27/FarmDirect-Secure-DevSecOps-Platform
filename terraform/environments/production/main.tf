locals {
  name = "farmdirect-staging"
  tags = {
    Project     = "FarmDirect"
    Environment = var.environment
  }
}

module "network" {
  source = "../../modules/network"

  name               = local.name
  vpc_cidr           = var.vpc_cidr
  eks_cluster_name   = var.eks_cluster_name
  public_subnets     = var.public_subnets
  app_subnets        = var.app_subnets
  db_subnets         = var.db_subnets
  enable_nat_gateway = var.enable_nat_gateway
  tags               = local.tags
}

module "security" {
  source = "../../modules/security"

  name   = local.name
  vpc_id = module.network.vpc_id
  tags   = local.tags
}

module "iam" {
  source = "../../modules/iam"

  name = local.name
  tags = local.tags
}

module "ecr" {
  source = "../../modules/ecr"

  name = local.name
  tags = local.tags
}

module "eks" {
  source = "../../modules/eks"

  depends_on                = [module.iam]
  cluster_name              = var.eks_cluster_name
  environment               = var.environment
  kubernetes_version        = var.kubernetes_version
  cluster_role_arn          = module.iam.cluster_role_arn
  node_role_arn             = module.iam.node_role_arn
  subnet_ids                = module.network.app_subnet_ids
  cluster_security_group_id = module.security.cluster_security_group_id
  node_security_group_id    = module.security.node_security_group_id
  instance_type             = var.node_instance_type
  desired_nodes             = var.desired_nodes
  min_nodes                 = var.min_nodes
  max_nodes                 = var.max_nodes
  cluster_log_types         = var.cluster_log_types
  tags                      = local.tags
}

module "irsa" {
  source = "../../modules/irsa"

  depends_on  = [module.eks]
  oidc_issuer = module.eks.oidc_issuer
  tags        = local.tags
}

module "load_balancer_controller" {
  source = "../../modules/load_balancer_controller"

  depends_on        = [module.irsa]
  name              = local.name
  oidc_provider_arn = module.irsa.provider_arn
  oidc_issuer       = module.eks.oidc_issuer
  tags              = local.tags
}

module "database" {
  count  = var.create_database ? 1 : 0
  source = "../../modules/database"

  name              = local.name
  subnet_ids        = module.network.db_subnet_ids
  security_group_id = module.security.db_security_group_id
  database_name     = var.database_name
  database_username = var.database_username
  database_password = var.database_password
  tags              = local.tags
}

module "secrets" {
  count  = var.create_secrets ? 1 : 0
  source = "../../modules/secrets"

  name              = local.name
  database_name     = var.database_name
  database_username = var.database_username
  database_password = var.database_password
  jwt_secret        = var.jwt_secret
  tags              = local.tags
}

module "logging" {
  source = "../../modules/logging"
  name   = local.name
  tags   = local.tags
}

module "acm" {
  source             = "../../modules/acm"
  domain_name        = var.domain_name
  zone_id            = var.route53_zone_id
  create_certificate = var.create_acm_certificate
  tags               = local.tags
}

module "endpoints" {
  source = "../../modules/endpoints"

  name                       = local.name
  vpc_id                     = module.network.vpc_id
  vpc_cidr                   = var.vpc_cidr
  region                     = var.aws_region
  subnet_ids                 = module.network.app_subnet_ids
  route_table_ids            = module.network.app_route_table_ids
  create_endpoints           = var.create_vpc_endpoints
  create_interface_endpoints = var.enable_interface_endpoints
  tags                       = local.tags
}