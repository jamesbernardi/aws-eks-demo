#REDIS VARIABLES
data "aws_availability_zones" "available" {
  state = "available"
}
variable "name" {}
variable "project" {}
variable "client" {}
variable "termination_protection" { default = "false" }
variable "vpc_id" {}
variable "redis_node_type" {}
variable "redis_engine_version" { default = "6.x" }
variable "replication_group_description" {}
variable "redis_parameter_group" { default = "default.redis6.x" }
variable "elasticache_subnetgroup" {}
variable "azs" {}
variable "node_sg" {}
variable "environment" {}
