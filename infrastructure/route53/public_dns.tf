resource "aws_route53_zone" "public" {
  name    = "${var.domain_name}.${var.dns_suffix}"
  comment = "Delegated from Infrastructure AWS account - Managed by Terraform"
}

data "aws_route53_zone" "f1" {
  provider = aws.infrastructure
  name     = var.dns_suffix
}

resource "aws_route53_record" "NS" {
  provider = aws.infrastructure
  zone_id  = data.aws_route53_zone.f1.zone_id
  name     = var.domain_name
  type     = "NS"
  ttl      = "30"
  records  = aws_route53_zone.public.name_servers
}
