locals {
  env = {
    default = {
      vpc_cidr             = "10.0.0.0/16"
      region               = "us-east-2"
      project              = "aws-eks-demo"
      client               = "jamesbernardi"
      department           = "demo"
      environment          = "${terraform.workspace}"
      aws_account_id       = ""
      eks_cluster_version  = "1.23"
      enable_cni_ipv6      = true
      min_capacity         = "3"
      max_capacity         = "10"
      instance_type        = "t3a.medium"
      db_instance_class    = "db.t3.medium"
      cluster_ip_family    = "ipv6"
      redis_node_type      = "cache.t4g.small"
      redis_engine_version = "6.x"
      ecr_repos = [
        "${terraform.workspace}-static",
      ]
    }
    dev = {
      vpc_cidr          = "172.26.0.0/16"
      instance_type     = "t3a.large"
      enable_cni_ipv6   = false
      cluster_ip_family = "ipv4"
      ecr_repos = [
        "${terraform.workspace}-static",
      ]
    }
    pre-prod = {
      vpc_cidr        = "172.27.0.0/16"
      enable_cni_ipv6 = false
      instance_type   = "t3a.small"
    }
    main = {
      vpc_cidr    = "172.30.0.0/16"
      environment = "production"
    }
  }
  environmentvars = contains(keys(local.env), terraform.workspace) ? terraform.workspace : "default"
  workspace       = merge(local.env["default"], local.env[local.environmentvars])
}
