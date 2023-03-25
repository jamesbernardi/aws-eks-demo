module "efs_csi" {
  source         = "./efs_csi_charts"
  eks_cluster_id = "${local.workspace["project"]}-${local.workspace["environment"]}"
  environment    = local.workspace["environment"]
  region         = local.workspace["region"]
}

module "traefik" {
  source         = "./traefik_charts"
  eks_cluster_id = "${local.workspace["project"]}-${local.workspace["environment"]}"
  region         = local.workspace["region"]
}

module "fluentbit" {
  source       = "./fluentbit_helm"
  logGroupName = "${local.workspace["project"]}-${local.workspace["environment"]}"
  region       = local.workspace["region"]
}

module "cloudwatch" {
  source         = "./cloudwatch_agent"
  eks_cluster_id = "${local.workspace["project"]}-${local.workspace["environment"]}"
}

module "autoscaler" {
  source         = "./autoscaler"
  eks_cluster_id = "${local.workspace["project"]}-${local.workspace["environment"]}"
}

module "cluster_roles" {
  source = "./cluster_roles"
}
