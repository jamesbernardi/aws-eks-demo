#CREATE VPC AND SUBNETS
module "vpc" {
  source                               = "terraform-aws-modules/vpc/aws"
  version                              = "~> 3.14.2"
  name                                 = var.vpc_name
  azs                                  = data.aws_availability_zones.available.names
  manage_default_security_group        = true
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 600
  default_vpc_enable_dns_hostnames     = true
  default_vpc_enable_dns_support       = true
  dhcp_options_domain_name             = "${var.vpc_name}.internal"
  dhcp_options_domain_name_servers     = ["AmazonProvidedDNS"]
  enable_dhcp_options                  = true
  enable_dns_hostnames                 = true
  enable_dns_support                   = true
  enable_nat_gateway                   = true
  single_nat_gateway                   = false
  one_nat_gateway_per_az               = true
  create_igw                           = true

  cidr                            = var.vpc_cidr
  private_subnets                 = [for i in range(var.azs) : cidrsubnet(module.vpc.vpc_cidr_block, 8, i)]
  public_subnets                  = [for i in range(var.azs) : cidrsubnet(module.vpc.vpc_cidr_block, 8, i + "10")]
  database_subnets                = [for i in range(var.azs) : cidrsubnet(module.vpc.vpc_cidr_block, 8, i + "20")]
  elasticache_subnets             = [for i in range(var.azs) : cidrsubnet(module.vpc.vpc_cidr_block, 8, i + "30")]
  create_database_subnet_group    = true
  create_elasticache_subnet_group = true

  enable_ipv6                                        = true
  assign_ipv6_address_on_creation                    = true
  private_subnet_assign_ipv6_address_on_creation     = true
  private_subnet_ipv6_prefixes                       = [for i in range(var.azs) : i + "10"]
  public_subnet_ipv6_prefixes                        = [for i in range(var.azs) : i + "20"]
  database_subnet_ipv6_prefixes                      = [for i in range(var.azs) : i + "30"]
  elasticache_subnet_ipv6_prefixes                   = [for i in range(var.azs) : i + "40"]
  database_subnet_assign_ipv6_address_on_creation    = true
  elasticache_subnet_assign_ipv6_address_on_creation = true


  public_subnet_tags = {
    "kubernetes.io/cluster/${var.eks_cluster_id}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.eks_cluster_id}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }

  tags = {
    "kubernetes.io/cluster/${var.eks_cluster_id}" = "shared"
  }

}

module "endpoints" {
  source             = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version            = "~> 3.14.2"
  vpc_id             = module.vpc.vpc_id
  security_group_ids = [module.vpc.default_security_group_id]

  endpoints = {
    s3 = {
      service = "s3"
      tags    = { Name = "s3-vpc-endpoint" }
    }
  }
}
