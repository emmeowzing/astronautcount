variable "public-eip" {
  type = string
}

variable "circleci-token" {
  type      = string
  sensitive = true
}
variable "circleci-project" {}
variable "circleci-organization" {}
