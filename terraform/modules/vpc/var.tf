variable "VPC_NAME" {}
variable "RESOURCE_PREFIX" {
  
}
variable "azs" {
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}
variable "create_route" {
  type    = bool
  default = true  # Set to false in environments where the route already exists
}