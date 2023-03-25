locals {
  # Common tags to be assigned to all resources
  common_tags = {
    project     = local.workspace["project"]
    client      = local.workspace["client"]
    department  = local.workspace["department"]
    Managed_By  = "Terraform"
    environment = local.workspace["environment"]
    team        = "sre"
  }
}
