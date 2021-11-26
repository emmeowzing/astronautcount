variable "godaddy_key" {
  type      = string
  sensitive = true
}

variable "godaddy_secret" {
  type      = string
  sensitive = true
}

variable "domain" { type = string }

variable "records" {
  type = list(map(string))
}
