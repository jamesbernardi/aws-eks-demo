# Add Permissions for Forumone Developers
resource "kubernetes_manifest" "efs-forumone-storage-role" {
  manifest = yamldecode(<<-EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole

metadata:
  name: forumone-developer

rules:
  - apiGroups: [""]
    resources: [pods, pods/log]
    verbs: [get, watch, list]

  - apiGroups: [""]
    resources: [pods/exec]
    verbs: [get, create]

  - apiGroups: [""]
    resources: [services, configmaps, persistentvolumeclaims, secrets]
    verbs: [get, watch, list, create, patch, update, delete]

  - apiGroups: ["", events.k8s.io]
    resources: [events]
    verbs: [get, list]

  - apiGroups: [apps]
    resources: [deployments]
    verbs: [get, watch, list, create, patch, update, delete]

  - apiGroups: [autoscaling]
    resources: [horizontalpodautoscalers]
    verbs: [get, watch, list, create, patch, update, delete]

  - apiGroups: [policy]
    resources: [poddisruptionbudgets]
    verbs: [get, watch, list, create, patch, update, delete]

  - apiGroups: [traefik.containo.us]
    resources: [ingressroutes, middlewares]
    verbs: [get, watch, list, create, patch, update, delete]

  - apiGroups: [forumone.com]
    resources: [mysqlusers, mysqldatabases]
    verbs: [get, watch, list]

  - apiGroups: [batch]
    resources: [jobs, cronjobs]
    verbs: [get, watch, list, create, patch, update, delete]

  - apiGroups: [batch]
    resources: [jobs/status, cronjob/status]
    verbs: [get]
      EOF
  )
}
