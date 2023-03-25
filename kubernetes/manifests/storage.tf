resource "kubernetes_manifest" "efs-sc" {
  manifest = yamldecode(<<-EOF
    kind: StorageClass
    apiVersion: storage.k8s.io/v1
    metadata:
      name: efs-sc
    provisioner: efs.csi.aws.com
    parameters:
      provisioningMode: efs-ap
      fileSystemId: ${var.efs_id}
      directoryPerms: "700"
      gidRangeStart: "1000"
      gidRangeEnd: "2000"
      basePath: ${var.environment}
  EOF
  )
}
