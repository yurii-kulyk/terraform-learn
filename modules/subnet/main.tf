resource "aws_subnet" "dev-subnet-1" {
  vpc_id            = var.vpc_id
  cidr_block        = var.subnet_cidr_block
  availability_zone = "eu-west-2a"
  tags = {
    Name : "${var.env_prefix}-subnet-1"
  }
}

resource "aws_internet_gateway" "dev-gateway" {
  vpc_id = var.vpc_id

  tags = {
    Name : "${var.env_prefix}-igw"
  }
}

resource "aws_default_route_table" "main-rtb" {
  default_route_table_id = var.default_route_table_id

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
