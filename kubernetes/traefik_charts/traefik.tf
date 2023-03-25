resource "helm_release" "traefik" {
  chart            = "traefik"
  name             = "traefik"
  timeout          = "1800"
  repository       = "https://helm.traefik.io/traefik"
  version          = "10.19.4"
  create_namespace = true
  namespace        = "traefik"
  replace          = true
  set {
    name  = "deployment.kind"
    value = "DaemonSet"
  }
  set {
    name  = "ports.web.hostPort"
    value = "8000"
  }
  set {
    name  = "ports.websecure.hostPort"
    value = "8443"
  }
  set {
    name  = "service.type"
    value = "NodePort"
  }
  set {
    name  = "ports.web.redirectTo"
    value = "websecure"
  }
}
