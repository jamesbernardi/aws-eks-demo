resource "helm_release" "efs-eks" {
  chart            = "aws-efs-csi-driver"
  name             = "aws-efs-csi-driver"
  timeout          = "1800"
  repository       = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
  version          = "2.2.6"
  create_namespace = false
  replace          = true
  namespace        = "kube-system"
  force_update     = true
  recreate_pods    = true
  cleanup_on_fail  = true
  set {
    name  = "controller.serviceAccount.create"
    value = "false"
  }
  set {
    name  = "controller.serviceAccount.name"
    value = "efs-csi-controller-sa"
  }
  set {
    name  = "image.repository"
    value = "602401143452.dkr.ecr.${var.region}.amazonaws.com/eks/aws-efs-csi-driver"
  }
}
