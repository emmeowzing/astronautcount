data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_region" "region" {}

resource "aws_iam_instance_profile" "astronautcount" {
  name = "astronautcount"
  role = aws_iam_role.astronautcount.name
}

resource "aws_iam_role" "astronautcount" {
  description = "Allow instances to reassign EIPs to themselves"
  inline_policy {
    name   = "astronautcount"
    policy = data.aws_iam_policy_document.ec2.json
  }

  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "assume_role" {
  version = "2012-10-17"

  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = toset(["ec2.amazonaws.com"])
    }
  }
}

data "aws_iam_policy_document" "ec2" {
  version = "2012-10-17"

  statement {
    actions   = ["ec2:*"]
    effect    = "Allow"
    resources = ["*"]
  }
}

resource "aws_launch_template" "astronautcount" {
  name                   = "astronautcount"
  image_id               = data.aws_ami.ubuntu.id
  instance_type          = var.instance-type
  user_data              = data.template_cloudinit_config.astronautcount.rendered
  vpc_security_group_ids = [aws_security_group.astronautcount-ingress.id]

  iam_instance_profile {
    arn = aws_iam_instance_profile.astronautcount.arn
  }

  lifecycle {
    create_before_destroy = true
  }

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      encrypted             = true
      delete_on_termination = true
      volume_size           = var.root-block-device-size
      volume_type           = "gp2"
    }
  }

  placement {
    availability_zone = element(data.aws_availability_zones.available.names, 0)
  }

  # There is some kind of bug with reusing the same EIP in an ASG while referencing a template - not sure why.
  # Instead, I've opted to re-associate the ENI/EIP with an instance with cloud-init and by assigning an instance profile -
  # https://forums.aws.amazon.com/message.jspa?messageID=864259
  # Error: Error creating Auto Scaling Group: ValidationError: You must use a valid fully-formed launch template. A network interface may not specify both a network interface ID and a subnet

  #network_interfaces {
  #  description = "ENI with a static IP address"
  #  delete_on_termination = false
  #  device_index = 0
  #  associate_public_ip_address = false
  #  security_groups = [aws_security_group.astronautcount-ingress.id]
  #  subnet_id = ""
  #  network_interface_id = aws_network_interface.reused.id
  #}
}

resource "aws_autoscaling_group" "astronautcount" {
  name                      = "astronautcount"
  max_size                  = var.asg-max-size
  min_size                  = var.asg-min-size
  desired_capacity          = var.asg-min-size
  force_delete              = false
  health_check_grace_period = var.asg-health-check-grace-period
  health_check_type         = "ELB"
  termination_policies      = ["NewestInstance"]
  max_instance_lifetime     = 31536000 # one year
  availability_zones        = toset([element(data.aws_availability_zones.available.names, 0)])

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.astronautcount.id
        version            = "$Latest"
      }

      dynamic "override" {
        for_each = var.spot-instance-list

        content {
          instance_type     = override.value["instance_type"]
          weighted_capacity = override.value["weighted_capacity"]
        }
      }
    }
    instances_distribution {
      # Try to be 100% spot-allocated, instead of on-demand, to keep cost to a minimum.
      on_demand_allocation_strategy            = "prioritized"
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 0
      spot_allocation_strategy                 = "lowest-price"
      spot_instance_pools                      = 4

      # The on-demand price of each instance type is the maximum I'm willing to pay.
      spot_max_price = ""
    }
  }

  tag {
    key                 = "Name"
    value               = var.instance-name-prefix != "" ? "${var.instance-name-prefix}-${data.aws_region.region.name}" : "astronautcount-${data.aws_region.region.name}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Owner"
    value               = var.instance-owner
    propagate_at_launch = true
  }
}
