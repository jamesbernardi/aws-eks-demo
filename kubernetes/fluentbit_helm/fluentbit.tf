resource "helm_release" "fluentbit" {
  chart            = "aws-for-fluent-bit"
  name             = "fluent-bit"
  timeout          = "1800"
  repository       = "https://aws.github.io/eks-charts"
  create_namespace = true
  replace          = true
  namespace        = "fluent-bit"
  version          = "0.1.16"
  set {
    name  = "cloudWatch.region"
    value = var.region
  }
  set {
    name  = "cloudWatch.logGroupName"
    value = var.logGroupName
  }
  set {
    name  = "kinesis.enabled"
    value = "false"
  }
  set {
    name  = "elasticsearch.enabled"
    value = "false"
  }
  set {
    name  = "firehose.enabled"
    value = "false"
  }
}
