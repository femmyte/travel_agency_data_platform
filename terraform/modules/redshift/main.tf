resource "aws_redshift_cluster" "example" {
  cluster_identifier = "tf-redshift-cluster"
  database_name      = "mydb"
  master_username    = "exampleuser"
  master_password    = "Mustbe8characters"
  node_type          = "dc2.large"
  cluster_type       = "multi-node"
  number_of_nodes = 2
  cluster_subnet_group_name = var.subnet_group_id
  skip_final_snapshot = true
  iam_roles = [ var.redshift_role_arn]
}