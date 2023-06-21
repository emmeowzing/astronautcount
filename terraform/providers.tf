terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.76.1"
    }

    circleci = {
      source  = "mrolla/circleci"
      version = "0.5.1"
    }

    godaddy = {
      source  = "n3integration/godaddy"
      version = "1.8.7"
    }
  }
}
