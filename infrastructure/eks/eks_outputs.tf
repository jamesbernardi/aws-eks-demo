output "aws_auth_configmap_yaml" {
  description = "Formatted yaml output for base aws-auth configmap containing roles used in cluster node groups/fargate profiles"
  value       = module.eks.aws_auth_configmap_yaml
}

output "eks_cluster_id" {
  description = "Name of the EKS Cluster"
  value       = module.eks.cluster_id
}

output "node_sg" {
  description = "Node SG for EKS"
  value       = module.eks.node_security_group_id
}

output "eks_managed_node_groups" {
  value = module.eks.eks_managed_node_groups
}

output "eks_managed_node_groups_autoscaling_group_names" {
  value = module.eks.eks_managed_node_groups_autoscaling_group_names
}
