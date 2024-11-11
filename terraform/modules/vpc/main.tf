resource "aws_vpc" "femmyte_vpc" {
  cidr_block = "172.16.0.0/16"
}

resource "aws_subnet" "redshift_subnet_a" {
  vpc_id     = aws_vpc.femmyte_vpc.id
  cidr_block ="172.16.24.0/24"
 availability_zone = var.azs[0]
  tags = {
    Name = "zone_a"
  }
}

resource "aws_subnet" "redshift_subnet_b" {
  vpc_id     = aws_vpc.femmyte_vpc.id
  cidr_block = "172.16.25.0/24"
 availability_zone = var.azs[1]
  tags = {
    Name = "zone_b"
  }
}

resource "aws_redshift_subnet_group" "redshift_subnet_group" {
  name       = "foo"
  subnet_ids = [aws_subnet.redshift_subnet_a.id, aws_subnet.redshift_subnet_b.id]

  tags = {
    environment = "redshift subnet group"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.femmyte_vpc.id

  tags = {
    Name = "femmyte_igw"
  }
}

resource "aws_route_table" "default" {
  vpc_id = aws_vpc.femmyte_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.redshift_subnet_a.id
  route_table_id = aws_route_table.default.id
}
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.redshift_subnet_b.id
  route_table_id = aws_route_table.default.id
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.femmyte_vpc.id

  ingress {
    description = "Allow inbound connections from Redshift"
    protocol  = "tcp"
    from_port = 5439
    to_port   = 5439
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Namw" = "redshift_security_group"
  }
}