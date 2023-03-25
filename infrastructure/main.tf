module "vpc" {
  source         = "./vpc"
  project        = local.workspace["project"]
  client         = local.workspace["client"]
  vpc_name       = "${local.workspace["project"]}-${local.workspace["environment"]}"
  eks_cluster_id = "${local.workspace["project"]}-${local.workspace["environment"]}"
  vpc_cidr       = local.workspace["vpc_cidr"]
  environment    = local.workspace["environment"]
}

module "eks" {
  source              = "./eks"
  eks_cluster_id      = "${local.workspace["project"]}-${local.workspace["environment"]}"
  eks_cluster_version = local.workspace["eks_cluster_version"]
  vpc_id              = module.vpc.vpc_id
  private_subnets     = module.vpc.private_subnets
  vpc_cidr            = local.workspace["vpc_cidr"]
  min_capacity        = local.workspace["min_capacity"]
  max_capacity        = local.workspace["max_capacity"]
  instance_type       = local.workspace["instance_type"]
  enable_cni_ipv6     = local.workspace["enable_cni_ipv6"]
  cluster_ip_family   = local.workspace["cluster_ip_family"]
  security_groups     = [module.nlb.sg]
  project             = local.workspace["project"]
  environment         = local.workspace["environment"]
}

module "mysql" {
  source                = "./mysql"
  cluster_identifier    = "${local.workspace["project"]}-${local.workspace["environment"]}"
  project               = local.workspace["project"]
  environment           = local.workspace["environment"]
  client                = local.workspace["client"]
  vpc_id                = module.vpc.vpc_id
  db_instance_class     = local.workspace["db_instance_class"]
  mysql_rds_subnetgroup = module.vpc.database_subnet_group_name
  node_sg               = module.eks.node_sg
}

module "route53" {
  source      = "./route53"
  domain_name = "${local.workspace["project"]}-${local.workspace["environment"]}"
  dns_suffix  = var.dns_suffix
  providers   = { aws.infrastructure = aws.infrastructure }
  project     = local.workspace["project"]
  environment = local.workspace["environment"]
}

module "acm" {
  source      = "./acm"
  default_acm = "${local.workspace["project"]}-${local.workspace["environment"]}"
  zone_id     = module.route53.zone_id
  dns_suffix  = var.dns_suffix
  project     = local.workspace["project"]
  environment = local.workspace["environment"]
}

module "nlb" {
  source              = "./nlb"
  name                = "${local.workspace["project"]}-${local.workspace["environment"]}"
  vpc_id              = module.vpc.vpc_id
  random              = random_string.name.result
  public_subnets      = module.vpc.public_subnets
  default_acm         = module.acm.default_acm
  eks_cluster_id      = module.eks.eks_cluster_id
  vpc_cidr            = local.workspace["vpc_cidr"]
  vpc_ipv6_cidr       = module.vpc.ipv6_cidr
  zone_id             = module.route53.zone_id
  node_sg             = module.eks.node_sg
  project             = local.workspace["project"]
  environment         = local.workspace["environment"]
  auto_scaling_groups = module.eks.eks_managed_node_groups_autoscaling_group_names
}

module "cloudwatch" {
  source = "./cloudwatch"
  name   = "${local.workspace["project"]}-${local.workspace["environment"]}"
}

module "ecr" {
  source   = "./ecr"
  for_each = toset("${local.workspace["ecr_repos"]}")
  name     = each.value
}

module "redis" {
  source                        = "./redis"
  name                          = "${local.workspace["project"]}-${local.workspace["environment"]}"
  replication_group_description = "${local.workspace["project"]}-${local.workspace["environment"]}"
  project                       = local.workspace["project"]
  client                        = local.workspace["client"]
  vpc_id                        = module.vpc.vpc_id
  redis_node_type               = local.workspace["redis_node_type"]
  elasticache_subnetgroup       = module.vpc.elasticache_subnet_group_name
  redis_engine_version          = local.workspace["redis_engine_version"]
  azs                           = var.azs
  node_sg                       = module.eks.node_sg
  environment                   = local.workspace["environment"]
}

module "efs" {
  source          = "./efs"
  name            = "${local.workspace["project"]}-${local.workspace["environment"]}"
  creation_token  = "${local.workspace["project"]}-${local.workspace["environment"]}-${random_string.name.result}"
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  node_sg         = module.eks.node_sg
  project         = local.workspace["project"]
  environment     = local.workspace["environment"]
  client          = local.workspace["client"]
}
