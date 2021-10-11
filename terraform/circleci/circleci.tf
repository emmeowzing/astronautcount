resource "circleci_environment_variable" "public-eip" {
  name         = "PUBLIC_EIP"
  value        = var.public-eip
  project      = "astronautcount"
  organization = "bjd2385"
}
