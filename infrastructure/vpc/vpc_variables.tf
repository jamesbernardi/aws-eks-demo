variable "project" {}
variable "client" {}
variable "environment" {}
variable "eks_cluster_id" {}
variable "vpc_name" {}
variable "vpc_cidr" {}
variable "azs" { default = "3" }
data "aws_availability_zones" "available" {
  state = "available"
}
