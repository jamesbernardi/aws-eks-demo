module "nlb_log_bucket" {
  source                        = "terraform-aws-modules/s3-bucket/aws"
  version                       = "~> 3.3.0"
  bucket                        = "${var.name}-nlb-logs-${var.random}"
  acl                           = "log-delivery-write"
  force_destroy                 = true
  attach_lb_log_delivery_policy = true
}

module "nlb" {
  source             = "terraform-aws-modules/alb/aws"
  version            = "7.0.0"
  name               = "${var.name}-nlb"
  load_balancer_type = "network"
  vpc_id             = var.vpc_id
  ip_address_type    = "dualstack"
  subnets            = var.public_subnets
  access_logs = {
    bucket = module.nlb_log_bucket.s3_bucket_id
  }

  target_groups = [
    {
      backend_protocol = "TCP"
      backend_port     = 8000
      target_type      = "instance"
    },
    {
      backend_protocol = "TCP"
      backend_port     = 8443
      target_type      = "instance"
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "TLS"
      certificate_arn    = var.default_acm
      target_group_index = 1
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "TCP"
      target_group_index = 0
    }
  ]
}

# Attach ASG's to Target Groups
resource "aws_autoscaling_attachment" "asg_attachment_0" {
  autoscaling_group_name = var.auto_scaling_groups[0]
  lb_target_group_arn    = module.nlb.target_group_arns[0]
}

resource "aws_autoscaling_attachment" "asg_attachment_1" {
  autoscaling_group_name = var.auto_scaling_groups[0]
  lb_target_group_arn    = module.nlb.target_group_arns[1]
}

resource "aws_route53_record" "root" {
  zone_id = var.zone_id
  name    = ""
  type    = "A"
  alias {
    name                   = module.nlb.lb_dns_name
    zone_id                = module.nlb.lb_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "star" {
  zone_id = var.zone_id
  name    = "*"
  type    = "A"
  alias {
    name                   = module.nlb.lb_dns_name
    zone_id                = module.nlb.lb_zone_id
    evaluate_target_health = false
  }
}
