resource "aws_iam_role" "redshift_role"{
  name = "redshift_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "redshift.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "redshift-role"
  }
}