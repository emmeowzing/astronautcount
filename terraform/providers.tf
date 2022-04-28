terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.62.0"
    }

    circleci = {
      source  = "mrolla/circleci"
      version = "0.6.1"
    }

    godaddy = {
      source  = "n3integration/godaddy"
      version = "1.8.7"
    }
  }
}
