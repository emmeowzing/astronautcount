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

resource "aws_launch_template" "astronautcount" {
  name                   = "astronautcount"
  image_id               = data.aws_ami.ubuntu.id
  #vpc_security_group_ids = [aws_security_group.astronautcount-ingress.id]
  instance_type          = var.instance-type
  user_data              = data.template_cloudinit_config.astronautcount.rendered

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

  network_interfaces {
    description = "ENI with a static IP address"
    delete_on_termination = false
    device_index = 0
    associate_public_ip_address = true
    security_groups = [aws_security_group.astronautcount-ingress.id]
    subnet_id = aws_subnet.astronautcount.id
    network_interface_id = aws_network_interface.reused.id
  }
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

## Scale up ASG

resource "aws_cloudwatch_metric_alarm" "astronautcount-cpu-util-scale-up" {
  alarm_name          = "astronautcount-cpu-util-scale-up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"

  # 80% of available processing speed on an instance.
  threshold = "80"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.astronautcount.name
  }

  alarm_actions = [aws_autoscaling_policy.astronautcount-scale-up.arn]
}

resource "aws_autoscaling_policy" "astronautcount-scale-up" {
  name                   = "astronautcount-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "SimpleScaling"
  autoscaling_group_name = aws_autoscaling_group.astronautcount.name
}

## Scale down ASG

resource "aws_cloudwatch_metric_alarm" "astronautcount-cpu-util-scale-down" {
  alarm_name          = "astronautcount-cpu-util-scale-down"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"

  # 80% of available processing speed on an instance.
  threshold = "80"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.astronautcount.name
  }

  alarm_actions = [aws_autoscaling_policy.astronautcount-scale-down.arn]
}

resource "aws_autoscaling_policy" "astronautcount-scale-down" {
  name                   = "astronautcount-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "SimpleScaling"
  autoscaling_group_name = aws_autoscaling_group.astronautcount.name
}
