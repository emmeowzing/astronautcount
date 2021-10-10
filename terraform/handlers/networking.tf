data "aws_vpc" "default" {
  default = true
}

# Ensure the selected availability zones actually exist.
data "aws_availability_zones" "available" {
  state = "available"
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
