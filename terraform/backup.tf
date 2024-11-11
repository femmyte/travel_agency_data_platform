# resource "aws_vpc" "agency_vpc" {
#   cidr_block       = "172.16.0.0/16"
#   instance_tenancy = "default"

#   tags = {
#     Name = var.VPC_NAME
#   }
# }

# # create subnets for RDS instances
# resource "aws_subnet" "rds_subnets" {
#   count             = 3
#   vpc_id            = aws_vpc.agency_vpc.id
#   cidr_block        = element(["172.16.24.0/24", "172.16.25.0/24", "172.16.26.0/24"], count.index)
#   availability_zone = var.azs[count.index]
#   tags = {
#     Name = "${var.RESOURCE_PREFIX}-private-RDS-${element(["a", "b", "c"], count.index)}"
#   }
# }

# # create an internet gateway
# resource "aws_internet_gateway" "femmyte_igw" {
#   vpc_id = aws_vpc.agency_vpc.id

#   tags = {
#     Name = "Agency VPC Internet Gateway"
#   }
# }

# # create a route table for the VPC
# resource "aws_route_table" "femmyte_rt" {
#   vpc_id = aws_vpc.agency_vpc.id

#   route {
#     cidr_block           = "0.0.0.0"
#     gateway_id = aws_internet_gateway.femmyte_igw.id
#   }
#   tags = {
#     "Name" = "Agency VPC Route Table"
#   }
# }
# # resource "aws_route" "example_route" {
# #   route_table_id         = data.aws_route_table.femmyte_rt.id
# #   destination_cidr_block = "0.0.0.0/0"
# #   gateway_id             = aws_internet_gateway.femmyte_igw.id
# # }
# # associate the route table with the internet gateway
# resource "aws_route_table_association" "b" {
#   gateway_id     = aws_internet_gateway.femmyte_igw.id
#   route_table_id = aws_route_table.femmyte_rt.id
#   # route_table_id = data.aws_route_table.femmyte_rt.id
# }
