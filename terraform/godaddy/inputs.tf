variable "godaddy-key" {
  type      = string
  sensitive = true
}

variable "godaddy-secret" {
  type      = string
  sensitive = true
}

variable "domain" { type = string }

variable "name_servers" { type = list(string) }
