terraform {
  required_providers {
    godaddy = {
      source  = "n3integration/godaddy"
      version = "1.8.7"
    }
  }
}

provider "godaddy" {
  key    = var.godaddy_key
  secret = var.godaddy_secret
}
