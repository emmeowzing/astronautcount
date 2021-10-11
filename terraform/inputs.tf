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

variable "common-ingress" {
  default = [
    {
      name      = "SSH"
      protocol  = "tcp"
      from_port = 3301
      to_port   = 3301
    },
    {
      name      = "HTTPS"
      protocol  = "tcp"
      from_port = 443
      to_port   = 443
    }
  ]
} # type: List[Dict[String, Union[String, int]]]

variable "spot-instance-list" {
  type = list(map(string))
  default = [
    {
      instance_type     = "t2.micro"
      weighted_capacity = "1"
    },
    {
      instance_type     = "t3.nano"
      weighted_capacity = "10"
    }
  ]
}

variable "circleci-token" {
  type      = string
  sensitive = true
}
