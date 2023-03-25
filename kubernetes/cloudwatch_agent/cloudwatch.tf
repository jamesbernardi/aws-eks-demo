resource "kubernetes_namespace" "amazon-cloudwatch" {
  metadata {
    labels = {
      name = "amazon-cloudwatch"
    }
    name = "amazon-cloudwatch"
  }
}

resource "kubernetes_service_account_v1" "cloudwatch-agent" {
  metadata {
    name      = "cloudwatch-agent"
    namespace = "amazon-cloudwatch"
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

resource "kubernetes_manifest" "cloudwatch-agent-role-binding" {
  manifest = yamldecode(<<-EOF
    kind: ClusterRoleBinding
    apiVersion: rbac.authorization.k8s.io/v1
    metadata:
      name: cloudwatch-agent-role-binding
    subjects:
      - kind: ServiceAccount
        name: cloudwatch-agent
        namespace: amazon-cloudwatch
    roleRef:
      kind: ClusterRole
      name: cloudwatch-agent-role
      apiGroup: rbac.authorization.k8s.io
  EOF
  )
}

resource "kubernetes_manifest" "cwagentconfig" {
  manifest = yamldecode(<<-EOF
    apiVersion: v1
    data:
      cwagentconfig.json: |
        {
          "logs": {
            "metrics_collected": {
              "kubernetes": {
                "cluster_name": "${var.eks_cluster_id}",
                "metrics_collection_interval": 60
              }
            },
            "force_flush_interval": 5
          }
        }
    kind: ConfigMap
    metadata:
      name: cwagentconfig
      namespace: amazon-cloudwatch
  EOF
  )
}

resource "kubernetes_manifest" "cloudwatch-agent" {
  manifest = yamldecode(<<-EOF
    apiVersion: apps/v1
    kind: DaemonSet
    metadata:
      name: cloudwatch-agent
      namespace: amazon-cloudwatch
    spec:
      selector:
        matchLabels:
          name: cloudwatch-agent
      template:
        metadata:
          labels:
            name: cloudwatch-agent
        spec:
          containers:
            - name: cloudwatch-agent
              image: amazon/cloudwatch-agent:1.247350.0b251780
              resources:
                limits:
                  cpu:  200m
                  memory: 200Mi
                requests:
                  cpu: 200m
                  memory: 200Mi
              env:
                - name: HOST_IP
                  valueFrom:
                    fieldRef:
                      fieldPath: status.hostIP
                - name: HOST_NAME
                  valueFrom:
                    fieldRef:
                      fieldPath: spec.nodeName
                - name: K8S_NAMESPACE
                  valueFrom:
                    fieldRef:
                      fieldPath: metadata.namespace
                - name: CI_VERSION
                  value: "k8s/1.3.9"
              volumeMounts:
                - name: cwagentconfig
                  mountPath: /etc/cwagentconfig
                - name: rootfs
                  mountPath: /rootfs
                  readOnly: true
                - name: dockersock
                  mountPath: /var/run/docker.sock
                  readOnly: true
                - name: varlibdocker
                  mountPath: /var/lib/docker
                  readOnly: true
                - name: containerdsock
                  mountPath: /run/containerd/containerd.sock
                  readOnly: true
                - name: sys
                  mountPath: /sys
                  readOnly: true
                - name: devdisk
                  mountPath: /dev/disk
                  readOnly: true
          volumes:
            - name: cwagentconfig
              configMap:
                name: cwagentconfig
            - name: rootfs
              hostPath:
                path: /
            - name: dockersock
              hostPath:
                path: /var/run/docker.sock
            - name: varlibdocker
              hostPath:
                path: /var/lib/docker
            - name: containerdsock
              hostPath:
                path: /run/containerd/containerd.sock
            - name: sys
              hostPath:
                path: /sys
            - name: devdisk
              hostPath:
                path: /dev/disk/
          terminationGracePeriodSeconds: 60
          serviceAccountName: cloudwatch-agent
  EOF
  )
}
