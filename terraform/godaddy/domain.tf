resource "aws_route53_zone" "twitter" {
  name = var.domain
}

resource "godaddy_domain_record" "aperiodicity" {
  domain      = var.domain
  nameservers = aws_route53_zone.twitter.name_servers

  dynamic "record" {
    for_each = var.records
    content {
      name = record.value["name"] # subdomain
      type = record.value["type"] # A record, etc.
      data = record.value["data"] # forwarding domain, etc.
    }
  }
}
