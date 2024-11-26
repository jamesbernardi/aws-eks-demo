# Create namespace per application
resource "kubernetes_namespace" "application" {
  metadata {
    annotations = {
      name = var.namespace
    }
    name = var.namespace
  }
}
resource "kubernetes_manifest" "namespace-role-binding" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind"       = "RoleBinding"
    "metadata" = {
      "name"      = "jamesbernardi-developer"
      "namespace" = "${var.namespace}"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind"     = "ClusterRole"
      "name"     = "jamesbernardi-developer"
    }
    "subjects" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind"     = "Group"
      "name"     = "jamesbernardi-developers"
    }
  }
}
