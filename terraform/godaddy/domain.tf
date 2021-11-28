resource "godaddy_domain_record" "aperiodicity" {
  domain      = var.domain
  nameservers = var.name_servers
}
