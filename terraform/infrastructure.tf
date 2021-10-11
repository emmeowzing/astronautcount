module "webhook_handler" {
  source = "./handlers/"

  region                        = var.region
  instance-name-prefix          = var.instance-name-prefix
  root-block-device-size        = var.root-block-device-size
  public-key                    = var.public-key
  ssh-public-key                = var.ssh-public-key
  instance-owner                = var.instance-owner
  instance-type                 = var.instance-type
  asg-health-check-grace-period = var.asg-health-check-grace-period
  asg-max-size                  = var.asg-max-size
  asg-min-size                  = var.asg-min-size
  common-ingress                = var.common-ingress
  spot-instance-list            = var.spot-instance-list
}
