data "aws_region" "current" {}

resource "aws_iam_role" "buildkite-eks-role" {
  name                  = "BuildkiteEKSRole-${var.eks_cluster_id}"
  description           = "Allows Buildkite stack to perform EKS and ECR tasks"
  managed_policy_arns   = ["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser", ]
  force_detach_policies = true
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : [
            "arn:aws:iam::165761832703:role/buildkite-Role",
            "arn:aws:iam::165761832703:role/buildkite-stack2-Role"
          ]
        },
        "Action" : "sts:AssumeRole",
        "Condition" : {}
      }
    ]
  })
}

data "aws_iam_policy_document" "buildkite_eks_policy" {
  statement {
    actions = [
      "eks:ListNodegroups",
      "eks:DescribeFargateProfile",
      "eks:ListTagsForResource",
      "eks:ListAddons",
      "eks:DescribeAddon",
      "eks:ListFargateProfiles",
      "eks:DescribeNodegroup",
      "eks:DescribeIdentityProviderConfig",
      "eks:ListUpdates",
      "eks:DescribeUpdate",
      "eks:AccessKubernetesApi",
      "eks:DescribeCluster",
      "eks:ListIdentityProviderConfigs"
    ]
    resources = ["arn:aws:eks:${data.aws_region.current.name}:${data.aws_caller_identity.current.id}:cluster/${var.eks_cluster_id}"]
  }
  statement {
    actions = [
      "eks:ListClusters",
      "eks:DescribeAddonVersions"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "buildkite_eks" {
  name        = "BuidkitePolicy-${var.eks_cluster_id}"
  policy      = data.aws_iam_policy_document.buildkite_eks_policy.json
  description = "Allows Buildkite to Access the ${var.eks_cluster_id} and create resources"
}

resource "aws_iam_role_policy_attachment" "buildkite_eks" {
  role       = aws_iam_role.buildkite-eks-role.name
  policy_arn = aws_iam_policy.buildkite_eks.arn
}
