resource "aws_route53_zone" "twitter" {
  name = var.domain
}

resource "aws_acm_certificate" "astronautcount" {
  domain_name       = var.fqdn
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}
