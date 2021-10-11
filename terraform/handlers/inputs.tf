variable "region" { default = "us-east-2" }
variable "instance-name-prefix" { default = "" }
variable "root-block-device-size" { default = 8 }
variable "public-key" {}
variable "ssh-public-key" {}
variable "instance-owner" {}
variable "instance-type" { default = "t2.micro" }
variable "asg-health-check-grace-period" {}
variable "asg-max-size" { default = 1 }
variable "asg-min-size" { default = 1 }
variable "common-ingress" {}
variable "spot-instance-list" { type = list(map(string)) }
