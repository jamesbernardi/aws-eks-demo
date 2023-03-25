resource "random_string" "name" {
  length  = 8
  special = false
  upper   = false
}
data "aws_availability_zones" "available" {
  state = "available"
}

variable "azs" { default = "3" }
variable "aws_region" { default = "us-east-2" }
variable "suffix" { default = "byf1.dev" }
variable "vpc_cidr" { default = "10.0.0.0/16" }
variable "termination_protection" { default = "true" }
variable "env" { default = "development" }
variable "dns_suffix" { default = "byf1.dev" }
variable "ecr_repos" {
  type    = list(string)
  default = []
}
