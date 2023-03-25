terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.23.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.12.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.6.0"
    }
  }
  required_version = ">= 1.2.5"

  backend "s3" {
    # All backend resources are stored in us-east-2
    region = "us-east-2"

    # State buckets are named "f1-tf-state-${client_account}"
    bucket = "f1-tf-state-941336018678"
    key    = "eks-sandbox-dev-applications.tfstate"

    # The locks table is the same for every account
    dynamodb_table = "TerraformLocks"
  }
}

provider "aws" {
  region = local.workspace["region"]
  assume_role {
    role_arn = "arn:aws:iam::941336018678:role/BuildkiteTerraformRole"
  }
  default_tags {
    tags = local.common_tags
  }
  allowed_account_ids = ["941336018678"]
}

provider "aws" {
  alias               = "infrastructure"
  region              = "us-east-2"
  allowed_account_ids = ["569455045079"]
  default_tags {
    tags = local.common_tags
  }
}

data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "cluster" {
  name = "${local.workspace["project"]}-${local.workspace["environment"]}"
}

data "aws_eks_cluster_auth" "cluster" {
  name = "${local.workspace["project"]}-${local.workspace["environment"]}"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}
