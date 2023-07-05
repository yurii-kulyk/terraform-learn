resource "aws_default_security_group" "dev-sg" {
  vpc_id = var.vpc_id

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
    values = [var.image_name]
  }
}

resource "aws_key_pair" "server-key" {
  key_name   = "server-key"
  public_key = file(var.public_key_path)
}

resource "aws_instance" "dev-server" {
  ami           = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type

  subnet_id              = module.dev-subnet.subnet.id
  vpc_security_group_ids = [aws_default_security_group.dev-sg.id]
  availability_zone      = "eu-west-2a"

  associate_public_ip_address = true

  key_name = aws_key_pair.server-key.key_name

  user_data = file("entrypoint.sh")

  tags = {
    Name : "${var.env_prefix}-server"
  }
}
