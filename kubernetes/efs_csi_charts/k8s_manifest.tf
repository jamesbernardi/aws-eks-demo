resource "kubernetes_manifest" "efs-cni-role" {
  manifest = {
    "apiVersion" = "v1"
    "kind"       = "ServiceAccount"
    "metadata" = {
      "name"      = "efs-csi-controller-sa"
      "namespace" = "kube-system"
      "labels" = {
        "app.kubernetes.io/name" = "aws-efs-csi-driver"
      }
      "annotations" = {
        "eks.amazonaws.com/role-arn" = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/AmazonEKS-EFS-CSI-DriverRole-${var.environment}"
      }
    }
  }
}


resource "kubernetes_cluster_role_v1" "efs-jamesbernardi-storage-role" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind"       = "ClusterRole"
    "metadata" = {
      "name" = "jamesbernardi-storage"
    }
    "rules" = {
      "apiGroups" = [""]
      "resources" = ["persistentvolumes"]
      "verbs"     = ["get", "watch", "list", "create", "patch", "update", "delete"]
    }
  }
}


resource "kubernetes_cluster_role_v1" "cloudwatch-agent-role" {
  metadata {
    name = "cloudwatch-agent-role"
  }
  rule {
    api_groups = [""]
    resources  = ["pods", "nodes", "endpoints"]
    verbs      = ["list", "watch"]
  }
  rule {
    api_groups = ["apps"]
    resources  = ["replicasets"]
    verbs      = ["list", "watch"]
  }
  rule {
    api_groups = ["batch"]
    resources  = ["jobs"]
    verbs      = ["list", "watch"]
  }
  rule {
    api_groups = [""]
    resources  = ["nodes/proxy"]
    verbs      = ["get"]
  }
  rule {
    api_groups = [""]
    resources  = ["nodes/stats", "configmaps", "events"]
    verbs      = ["create"]
  }
  rule {
    api_groups     = [""]
    resources      = ["configmaps"]
    resource_names = ["cwagent-clusterleader"]
    verbs          = ["get", "update"]
  }
}
