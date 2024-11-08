resource "aws_vpc" "agency_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = var.VPC_NAME
  }
}

# create subnets for RDS instances
resource "aws_subnet" "rds_subnets" {
  count             = 3
  vpc_id            = aws_vpc.agency_vpc.id
  cidr_block        = element(["10.0.24.0/24", "10.0.25.0/24", "10.0.26.0/24"], count.index)
  availability_zone = var.azs[count.index]
  tags = {
    Name = "${var.RESOURCE_PREFIX}-private-RDS-${element(["a", "b", "c"], count.index)}"
  }
}

# create an internet gateway
resource "aws_internet_gateway" "femmyte_igw" {
  vpc_id = aws_vpc.agency_vpc.id

  tags = {
    Name = "Agency VPC Internet Gateway"
  }
}

# attach the internet gateway to the VPC
resource "aws_internet_gateway_attachment" "example" {
  internet_gateway_id = aws_internet_gateway.femmyte_igw.id
  vpc_id              = aws_vpc.agency_vpc.id
}

# create a network interface for the RDS instance to use as a network interface for the VPC
resource "aws_network_interface" "test" {
  count     = 3
  subnet_id = aws_subnet.rds_subnets[count.index].id
}

# create a route table for the VPC
resource "aws_route_table" "femmyte_rt" {
  vpc_id = aws_vpc.agency_vpc.id
  count = 3

  route {
    cidr_block           = aws_vpc.agency_vpc.cidr_block
    network_interface_id = aws_network_interface.test[count.index].id
  }
}

# associate the route table with the internet gateway
resource "aws_route_table_association" "b" {
  gateway_id     = aws_internet_gateway.femmyte_igw.id
  count = 3
  route_table_id = aws_route_table.femmyte_rt[count.index].id
}
