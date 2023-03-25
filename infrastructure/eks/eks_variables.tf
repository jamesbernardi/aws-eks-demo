variable "eks_cluster_id" {}
variable "eks_cluster_version" {}
variable "vpc_cidr" {}
variable "private_subnets" {}
variable "vpc_id" {}
variable "min_capacity" {}
variable "max_capacity" {}
variable "instance_type" {}
variable "enable_cni_ipv6" {}
variable "cluster_ip_family" {}
variable "security_groups" { default = "" }
variable "disk_size" { default = "150" }
variable "project" {}
variable "environment" {}
