provider "aws" {
  region  = "eu-west-2"
  profile = "work"
}


resource "aws_vpc" "development-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name : "${var.env_prefix}-vpc"
  }
}

module "dev-subnet" {
  source                 = "./modules/subnet"
  subnet_cidr_block      = var.subnet_cidr_block
  env_prefix             = var.env_prefix
  vpc_id                 = aws_vpc.development-vpc.id
  default_route_table_id = aws_vpc.development-vpc.default_route_table_id
}
