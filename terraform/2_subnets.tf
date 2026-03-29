

resource "aws_subnet" "public-us-east-2a" {
  vpc_id                  = aws_vpc.nti_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true

  tags = {
    "Name"                       = "public-us-east-2a"
    "kubernetes.io/role/elb" = "1"

  }
}

resource "aws_subnet" "public-us-east-2b" {
  vpc_id                  = aws_vpc.nti_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-2b"
  map_public_ip_on_launch = true

  tags = {
    "Name"                       = "public-us-east-2b"
    "kubernetes.io/role/elb" = "1"
  }
}

  



resource "aws_subnet" "private-us-east-2a" {
  vpc_id                  = aws_vpc.nti_vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = false
  tags = {
    "Name"                            = "private-us-east-2a"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/nti-eks-cluster" = "owned"
  }
}

resource "aws_subnet" "private-us-east-2b" {
  vpc_id                  = aws_vpc.nti_vpc.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "us-east-2b"
  map_public_ip_on_launch = false
  tags = {
    "Name"                            = "private-us-east-2b"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/nti-eks-cluster" = "owned"
  }
}