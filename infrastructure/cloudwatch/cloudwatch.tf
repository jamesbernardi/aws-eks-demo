module "log_group" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/log-group"
  version = "~> 3.3.0"

  name              = var.name
  retention_in_days = var.retention
}


variable "retention" { default = "30" }
variable "name" {}
