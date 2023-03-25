module "default_acm" {
  source                    = "terraform-aws-modules/acm/aws"
  version                   = "~> 4.0.1"
  domain_name               = "${var.default_acm}.${var.dns_suffix}"
  zone_id                   = var.zone_id
  subject_alternative_names = ["*.${var.default_acm}.${var.dns_suffix}"]
  wait_for_validation       = true
  validate_certificate      = true
}
