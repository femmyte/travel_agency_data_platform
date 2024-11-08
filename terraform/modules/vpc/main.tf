resource "aws_vpc" "agency_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = var.VPC_NAME
  }
}

resource "aws_subnet" "rds_subnets" {
  count             = 3
  vpc_id            = aws_vpc.agency_vpc.id
  cidr_block        = element(["10.0.24.0/24", "10.0.25.0/24", "10.0.26.0/24"], count.index)
  availability_zone = var.azs[count.index]
  tags = {
    Name = "${var.RESOURCE_PREFIX}-private-RDS-${element(["a", "b", "c"], count.index)}"
  }
}
