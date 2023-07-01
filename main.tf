provider "aws" {
  region  = "eu-west-2"
  profile = "work"
}

variable "vpc_cidr_block" {

}

variable "subnet_cidr_block" {

}

variable "env_prefix" {

}

variable "my_ip" {

}

variable "instance_type" {

}

variable "public_key_path" {

}

resource "aws_vpc" "development-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name : "${var.env_prefix}-vpc"
  }
}

resource "aws_subnet" "dev-subnet-1" {
  vpc_id            = aws_vpc.development-vpc.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = "eu-west-2a"
  tags = {
    Name : "${var.env_prefix}-subnet-1"
  }
}

resource "aws_internet_gateway" "dev-gateway" {
  vpc_id = aws_vpc.development-vpc.id

  tags = {
    Name : "${var.env_prefix}-igw"
  }
}

resource "aws_default_route_table" "main-rtb" {
  default_route_table_id = aws_vpc.development-vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev-gateway.id
  }
  tags = {
    Name : "${var.env_prefix}-rtb"
  }
}

resource "aws_route_table_association" "a-rtb-subnet" {
  subnet_id      = aws_subnet.dev-subnet-1.id
  route_table_id = aws_default_route_table.main-rtb.id
}

resource "aws_default_security_group" "dev-sg" {
  vpc_id = aws_vpc.development-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    Name : "${var.env_prefix}-sg"
  }
}

data "aws_ami" "latest-amazon-linux-image" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_key_pair" "server-key" {
  key_name   = "server-key"
  public_key = file(var.public_key_path)
}

resource "aws_instance" "dev-server" {
  ami           = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type

  subnet_id              = aws_subnet.dev-subnet-1.id
  vpc_security_group_ids = [aws_default_security_group.dev-sg.id]
  availability_zone      = "eu-west-2a"

  associate_public_ip_address = true

  key_name = aws_key_pair.server-key.key_name

  user_data = file("entrypoint.sh")

  tags = {
    Name : "${var.env_prefix}-server"
  }
}

output "ec2_public_ip" {
  value = aws_instance.dev-server.public_ip

}
