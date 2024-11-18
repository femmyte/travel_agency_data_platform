terraform {
  backend "s3" {
    bucket = "femi-aws-ci-cd-logs"
    key    = "terrafor/project_state_file.tfstate"
    region = "us-east-1"
  }
}
