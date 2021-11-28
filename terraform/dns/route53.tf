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
