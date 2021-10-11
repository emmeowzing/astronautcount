terraform {
  required_providers {
    circleci = {
      source  = "mrolla/circleci"
      version = "0.5.1"
    }
  }
}

provider "circleci" {
  api_token = var.cirlceci-token
}
