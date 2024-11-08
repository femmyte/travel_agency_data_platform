

data "aws_subnet" "rds_main_subnet" {
  vpc_id = var.vpc_id
  tags = {
    Name = "${var.RESOURCE_PREFIX}-private-RDS-a"
  }
}
data "aws_subnet" "rds_second_subnet" {
  vpc_id = var.vpc_id
  tags = {
    Name = "${var.RESOURCE_PREFIX}-private-RDS-b"
  }
}

resource "aws_db_subnet_group" "mydb_subnet_group" {
  name       = "myrds-subnet-group"
  subnet_ids = [
    data.aws_subnet.rds_main_subnet.id,
    data.aws_subnet.rds_second_subnet.id
      ]
}

resource "aws_security_group" "postgres_sg" {
  name        = "dev-postgres-sg"
  description = "Security group for PostgreSQL"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "PostgresSG"
  }
}

resource "aws_rds_cluster" "postgresql" {
  cluster_identifier = "travel-agency"
  engine             = "aurora-postgresql"
  engine_mode        = "provisioned"
  engine_version     = "13.7"
  database_name      = "travel_agency"
  master_username    = "testAdmin"
  master_password    = "AdminTest4321"
  storage_encrypted  = true
  vpc_security_group_ids = [aws_security_group.postgres_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.mydb_subnet_group.name
  serverlessv2_scaling_configuration {
    max_capacity = 1.0
    min_capacity = 0.5
  }
}

# creating Aurora instance
resource "aws_rds_cluster_instance" "example" {
  cluster_identifier = aws_rds_cluster.postgresql.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.postgresql.engine
  engine_version     = aws_rds_cluster.postgresql.engine_version
}


# creating Aurora cluster
# resource "aws_rds_cluster" "aurorards" {
#   cluster_identifier     = "myauroracluster"
#   engine                 = "aurora-mysql"
#   engine_version         = "5.7.mysql_aurora.2.12.0"
#   database_name          = "MyDB"
#   master_username        = "testAdmin"
#   master_password        = "AdminTest4321"
#   vpc_security_group_ids = [aws_security_group.allow_aurora.id]
#   db_subnet_group_name   = aws_db_subnet_group.mydb_subnet_group.name
#   storage_encrypted      = false
#   skip_final_snapshot    = true
# }