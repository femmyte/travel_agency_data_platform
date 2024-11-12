resource "aws_ecr_repository" "travel_agency_ecr" {
  name                 = "travel_agency_ecr"
  image_tag_mutability = "MUTABLE"
  force_delete = true
  image_scanning_configuration {
    scan_on_push = true
  }
}