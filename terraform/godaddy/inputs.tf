variable "godaddy-key" {
  type      = string
  sensitive = true
}

variable "godaddy-secret" {
  type      = string
  sensitive = true
}

variable "domain" { type = string }

variable "records" {
  type = list(map(string))
}