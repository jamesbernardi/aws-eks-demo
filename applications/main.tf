module "efs" {
  source            = "./efs"
  for_each          = local.apps
  name              = each.key
  environments      = each.value.environments
  efs_access_points = each.value.efs_access_points
  project           = "${local.workspace["project"]}-${local.workspace["environment"]}"
}

module "kubernetes_namespace" {
  source    = "./kubernetes_namespace"
  for_each  = toset(local.namespaces)
  namespace = each.value
}

module "s3_backup" {
  source   = "./s3_backup"
  for_each = toset(local.names)
  bucket   = "${local.workspace["project"]}-${local.workspace["environment"]}-each.value"
}