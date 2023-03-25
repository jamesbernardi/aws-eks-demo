resource "kubernetes_manifest" "internet_egress" {
  manifest = yamldecode(<<-EOF
    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: internet-access
      namespace: internet-access
    spec:
      podSelector:
        matchLabels:
          networking/allow-internet-egress: "true"
      policyTypes:
      - Egress
      egress:
      - {}
  EOF
  )
}
