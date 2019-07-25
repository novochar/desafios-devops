variable "cloud" {
  type = string
  default = "us-west-2"
}

variable "range" {
  type = list(string)
  default = ["0.0.0.0/0"]
}

provider "aws" {
  region = var.cloud
}

data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"] # Canonical
}

resource "aws_vpc" "test_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_security_group" "test_group" {
  name        = "test_group"
  description = "test"
  vpc_id      = aws_vpc.test_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "0"
    cidr_blocks = var.range
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_subnet" "test_subnet" {
  vpc_id     = aws_vpc.test_vpc.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_internet_gateway" "test_gw" {
  vpc_id = aws_vpc.test_vpc.id
}

resource "aws_instance" "test_machine" {
  ami = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.test_group.id]
  subnet_id = aws_subnet.test_subnet.id
  depends_on = ["aws_internet_gateway.test_gw"]
}

resource "aws_eip" "test_eip" {
  instance = "${aws_instance.test_machine.id}"
  depends_on = ["aws_internet_gateway.test_gw"]
  vpc      = true
}

output "ip" {
    value = aws_eip.test_eip.public_ip
}

