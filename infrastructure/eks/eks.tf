data "aws_eks_cluster_auth" "eks_auth" {
  name = module.eks.cluster_id
}

data "aws_caller_identity" "current" {}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.eks_auth.token
}

resource "aws_kms_key" "eks" {
  description             = var.eks_cluster_id
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

data "aws_iam_roles" "sso_admins" {
  name_regex = ".*AWSReservedSSO_AdministratorAccess.*"
}

data "aws_iam_roles" "sso_devs" {
  name_regex = ".*AWSReservedSSO_KubernetesAccess.*"
}

module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = "~> 18.26.5"
  cluster_name                    = var.eks_cluster_id
  cluster_version                 = var.eks_cluster_version
  vpc_id                          = var.vpc_id
  subnet_ids                      = var.private_subnets
  cluster_ip_family               = var.cluster_ip_family
  create_cni_ipv6_iam_policy      = var.enable_cni_ipv6
  enable_irsa                     = true
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  create_iam_role                 = true
  create_node_security_group      = true
  cluster_encryption_config = [{
    provider_key_arn = aws_kms_key.eks.arn
    resources        = ["secrets"]
  }]
  cloudwatch_log_group_retention_in_days = 30

  # aws-auth configmap
  manage_aws_auth_configmap = true

  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.id}:role/${one(data.aws_iam_roles.sso_admins.names)}"
      username = "admin:{{SessionName}}"
      groups   = ["system:masters"]
    },
    {
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.id}:role/${one(data.aws_iam_roles.sso_devs.names)}"
      username = "jamesbernardi:{{SessionName}}"
      groups   = ["jamesbernardi-developers"]
    },
    {
      rolearn  = "${aws_iam_role.buildkite-eks-role.arn}"
      username = "jamesbernardi:{{SessionName}}"
      groups   = ["jamesbernardi-developers"]
    },
    # only for the dev stack - this role was manually created as a test
    {
      rolearn  = "arn:aws:iam::941336018678:role/BuildkiteECRRole"
      username = "jamesbernardi:{{SessionName}}"
      groups   = ["jamesbernardi-developers"]
    },
  ]

  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  eks_managed_node_group_defaults = {
    ami_type                     = "AL2_x86_64"
    disk_size                    = var.disk_size
    instance_types               = [var.instance_type]
    vpc_security_group_ids       = var.security_groups
    create_iam_role              = true
    iam_role_name                = var.eks_cluster_id
    iam_role_attach_cni_policy   = true
    iam_role_use_name_prefix     = false
    iam_role_description         = var.eks_cluster_id
    iam_role_additional_policies = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore", "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly", "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"]
    root_volume_type             = "gp3"
    cluster_name                 = module.eks.cluster_id
    vpc_id                       = var.vpc_id
    subnet_ids                   = var.private_subnets
    cluster_endpoint             = module.eks.cluster_endpoint
    cluster_ip_family            = var.cluster_ip_family
    cluster_security_group_id    = module.eks.cluster_security_group_id
  }

  eks_managed_node_groups = {
    "${var.eks_cluster_id}" = {
      desired_size  = var.min_capacity
      max_size      = var.max_capacity
      min_size      = var.min_capacity
      instance_type = var.instance_type
    }
  }
  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {
      resolve_conflicts = "OVERWRITE"
    }
    vpc-cni = {
      resolve_conflicts        = "OVERWRITE"
      service_account_role_arn = module.vpc_cni_irsa.iam_role_arn
    }
  }
}

#IRSA role

module "vpc_cni_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.3.0"

  role_name_prefix      = "VPC-CNI-IRSA"
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv6   = false
  vpc_cni_enable_ipv4   = true
  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }
}

#autoscaler role

module "cluster_autoscaler_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.3.0"

  role_name                        = "${var.eks_cluster_id}-autoscaler"
  attach_cluster_autoscaler_policy = true
  cluster_autoscaler_cluster_ids   = [module.eks.cluster_id]

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:cluster-autoscaler"]
    }
  }
}

################################################################################
# Tags for the ASG to support cluster-autoscaler scale up from 0
################################################################################

locals {
  cluster_autoscaler_label_tags = merge([
    for name, group in module.eks.eks_managed_node_groups : {
      for label_name, label_value in coalesce(group.node_group_labels, {}) : "${name}|label|${label_name}" => {
        autoscaling_group = group.node_group_autoscaling_group_names[0],
        key               = "k8s.io/cluster-autoscaler/node-template/label/${label_name}",
        value             = label_value,
      }
    }
  ]...)

}

resource "aws_autoscaling_group_tag" "cluster_autoscaler_label_tags" {
  for_each = local.cluster_autoscaler_label_tags

  autoscaling_group_name = each.value.autoscaling_group

  tag {
    key   = each.value.key
    value = each.value.value

    propagate_at_launch = false
  }
}
