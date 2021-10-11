resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

# Ensure the selected availability zones actually exist.
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "astronautcount" {
  availability_zone_id = data.aws_availability_zones.available.zone_ids[0]
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
}

resource "aws_network_interface" "reused" {
  subnet_id = aws_subnet.astronautcount.id
  description = "ENI to be reused in ASGed instances"
  security_groups = [aws_security_group.astronautcount-ingress.id]
}

resource "aws_eip" "static" {
  vpc = true
  network_interface = aws_network_interface.reused.id
}

resource "aws_security_group" "astronautcount-ingress" {
  vpc_id = aws_vpc.main.id

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
