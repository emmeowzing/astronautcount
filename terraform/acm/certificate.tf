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
  ttl     = 60
  records = [var.public-eip]
}

resource "aws_acm_certificate" "astronautcount" {
  domain_name       = local.fqdn
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "twitter-certs" {
  for_each = {
    for dvo in aws_acm_certificate.astronautcount.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      record  = dvo.resource_record_value
      type    = dvo.resource_record_type
      zone_id = aws_route53_zone.domain.zone_id
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = each.value.zone_id
}

resource "aws_acm_certificate_validation" "astronautcount" {
  certificate_arn         = aws_acm_certificate.astronautcount.arn
  validation_record_fqdns = [aws_route53_record.twitter.fqdn]

  depends_on = [aws_route53_record.twitter-certs]
}
