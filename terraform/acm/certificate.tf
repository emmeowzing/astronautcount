locals {
  fqdn = "${var.subdomain}.${var.domain}"
}


resource "aws_route53_zone" "domain" {
  name = var.domain
}

resource "aws_route53_record" "twitter" {
  zone_id = aws_route53_zone.domain.zone_id
  name    = local.fqdn
  type    = "A"
  ttl     = "300"
  records = [var.public-eip]
}

resource "aws_acm_certificate" "astronautcount" {
  domain_name       = local.fqdn
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "astronautcount" {
  certificate_arn         = aws_acm_certificate.astronautcount.arn
  validation_record_fqdns = [aws_route53_record.twitter.fqdn]
}
