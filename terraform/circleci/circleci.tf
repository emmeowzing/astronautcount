resource "circleci_environment_variable" "public-eip" {
  name         = "PUBLIC_EIP"
  value        = var.public-eip
  project      = var.circleci-project
  organization = var.circleci-organization
}
