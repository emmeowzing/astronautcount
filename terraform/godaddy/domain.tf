resource "godaddy_domain_record" "aperiodicity" {
  domain = var.domain

  dynamic "record" {
    for_each = var.records
    record {
      name = record.value["name"] # subdomain
      type = record.value["type"] # A record, etc.
      data = record.value["data"] # forwarding domain, etc.
    }
  }
}
