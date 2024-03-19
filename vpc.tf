resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "main"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-gw"
  }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "main-rt"
  }
}

resource "aws_subnet" "primary" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "primary"
  }
}

resource "aws_subnet" "standby" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "standby"
  }
}

resource "aws_subnet" "replica" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1c"

  tags = {
    Name = "replica"
  }
}


resource "aws_route_table_association" "a_primary" {
  subnet_id      = aws_subnet.primary.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "a_standby" {
  subnet_id      = aws_subnet.standby.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "a_replica" {
  subnet_id      = aws_subnet.replica.id
  route_table_id = aws_route_table.rt.id
}
