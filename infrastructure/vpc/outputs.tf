output "vpc_id" {
  value = module.vpc.vpc_id
}
output "private_subnets" {
  value = module.vpc.private_subnets
}
output "database_subnet_group_name" {
  value = module.vpc.database_subnet_group_name
}
output "public_subnets" {
  value = module.vpc.public_subnets
}
output "elasticache_subnet_group_name" {
  value = module.vpc.elasticache_subnet_group_name
}
output "ipv6_cidr" {
  value = module.vpc.vpc_ipv6_cidr_block
}
