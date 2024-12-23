locals {
  RESOURCE_PREFIX = "travel_agency"
  VPC_NAME        = "${local.RESOURCE_PREFIX}-vpc"
}

module "vpc" {
  source          = "./modules/vpc"
  RESOURCE_PREFIX = local.RESOURCE_PREFIX
  VPC_NAME            = local.VPC_NAME
}

module "s3" {
  source = "./modules/s3"

}

module "roles" {
  source = "./modules/roles"

}
module "redshift" {
  source = "./modules/redshift"
  subnet_group_id = module.vpc.subnet_group_id
  redshift_role_arn = module.roles.redshift_role_arn
  username = var.username
  password = var.password
  database_name = var.database_name
  cluster_identifier = var.cluster_identifier
}

module "ecr" {
  source = "./modules/ecr"
  ecr_name = var.ecr_name
}

# module "rds" {
#   source          = "./modules/rds"
#   vpc_name        = "${local.RESOURCE_PREFIX}-vpc"
#   vpc_id          = module.vpc.vpc_id
#   RESOURCE_PREFIX = local.RESOURCE_PREFIX
#   depends_on = [ module.vpc ]
# }
