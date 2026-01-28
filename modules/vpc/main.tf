provider "aws" {
  region = var.region
}


resource "aws_vpc" "my-vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "tf-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "tf-igw"
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"
}



resource "aws_subnet" "public_subnet" {
  count = length(var.public_subnet)
  vpc_id = aws_vpc.my-vpc.id
  cidr_block = var.public_subnet[count.index]
  availability_zone = var.az[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name ="public_subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  count = length(var.private_subnet)
  vpc_id = aws_vpc.my-vpc.id
  cidr_block = var.private_subnet[count.index]
  availability_zone = var.az[count.index]
tags = {
  Name = "private-sub"
}
}


resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat.id
  subnet_id = aws_subnet.public_subnet[0].id
  tags = {
    Name = "tf-nat-gw"
  }

  depends_on = [aws_internet_gateway.igw]
}


resource "aws_route_table" "public" {
  vpc_id = aws_vpc.my-vpc.id

  route  {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "pub-rt"
  }
}

resource "aws_route_table_association" "public_as" {
  count = length(aws_subnet.public_subnet)
  subnet_id = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "private-rt"
  }
  depends_on = [ aws_nat_gateway.nat_gw ]
}

resource "aws_route_table_association" "private_as" {
  count = length(aws_subnet.private_subnet)
  subnet_id = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private.id
}