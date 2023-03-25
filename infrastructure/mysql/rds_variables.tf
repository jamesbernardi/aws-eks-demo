#MYSQL RDS VARIABLES
data "aws_availability_zones" "available" {
  state = "available"
}
variable "cluster_identifier" {}
variable "project" {}
variable "client" {}
variable "environment" {}
variable "azs" { default = "3" }
variable "dbname" { default = "main" }
variable "termination_protection" { default = "false" }
variable "dbuser" { default = "root" }
variable "skip_final_snapshot" { default = "true" }
variable "mysql_rds_subnetgroup" {}
variable "aurora_mysql_engine_version" { default = "5.7.mysql_aurora.2.10.1" }
variable "db_instances" { default = "2" }
variable "db_instance_class" {}
variable "vpc_id" {}
variable "node_sg" {}

