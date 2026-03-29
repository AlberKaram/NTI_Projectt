######## igw ##########
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.nti_vpc.id
}

######## pub-rt ##########

resource "aws_route_table" "pub_rt" {
  vpc_id = aws_vpc.nti_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }


  tags = {
    Name = "pub_rt"
  }
}

######## subnet assossition ##########
resource "aws_route_table_association" "public_subnet_association_2a"{
  subnet_id      = aws_subnet.public-us-east-2a.id
  route_table_id = aws_route_table.pub_rt.id
}

resource "aws_route_table_association" "public_subnet_association_2b"{
  subnet_id      = aws_subnet.public-us-east-2b.id
  route_table_id = aws_route_table.pub_rt.id
}




######## eip ##########
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

######## ngw ##########
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public-us-east-2a.id

  tags = {
    Name = "nat-gateway"
  }
}


######## private_rt ##########

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.nti_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }


  tags = {
    Name = "private_rt"
  }
}

######## subnet assossition ##########
resource "aws_route_table_association" "private_subnet_association_2a" {
  subnet_id      = aws_subnet.private-us-east-2a.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_subnet_association_2b" {
  subnet_id      = aws_subnet.private-us-east-2b.id
  route_table_id = aws_route_table.private_rt.id
}