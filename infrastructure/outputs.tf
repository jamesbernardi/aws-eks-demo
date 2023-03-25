#output "aws_auth_configmap_yaml" {
#  description = "Formatted yaml output for base aws-auth configmap containing roles used in cluster node groups/fargate profiles"
#  value       = module.eks.aws_auth_configmap_yaml
#}
#
#output "targetgroups" { value = module.nlb.target_groups }

output "redis_host" { value = module.redis.host_name }
output "mysql_host" { value = module.mysql.host_name }

output "eks_managed_node_groups" {
  value = module.eks.eks_managed_node_groups
}

output "eks_managed_node_groups_autoscaling_group_names" {
  value = module.eks.eks_managed_node_groups_autoscaling_group_names
}
