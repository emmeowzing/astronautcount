data "aws_vpc" "default" {
  default = true
  cidr_block = "10.0.0.0/16"
}

# Ensure the selected availability zones actually exist.
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "astronautcount" {
  vpc_id = data.aws_vpc.default.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_network_interface" "astronautcount" {
  security_groups = [aws_security_group.astronautcount-ingress.id]
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
