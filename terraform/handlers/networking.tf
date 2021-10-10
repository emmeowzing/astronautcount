data "aws_vpc" "default" {
  default = true
}

# Ensure the selected availability zones actually exist.
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_instance" "astronautcount" {
  filter {
    name = "tag:Name"
    values = [var.instance-name-prefix != "" ? "${var.instance-name-prefix}-${data.aws_region.region.name}" : "astronautcount-${data.aws_region.region.name}"]
  }
}

resource "aws_eip" "astronautcount" {
  vpc = true
  instance = data.aws_instance.astronautcount.id
}

resource "aws_security_group" "astronautcount-ingress" {
  vpc_id = data.aws_vpc.default.id

  # Public subnet allowing ingress on common ports.
  dynamic "ingress" {
    for_each = var.common-ingress
    iterator = port

    content {
      description = port.value["name"]
      from_port   = port.value["from_port"]
      protocol    = port.value["protocol"]
      to_port     = port.value["to_port"]
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    description = "Open egress"
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "astronautcount-net"
  }
}
