resource "aws_s3_bucket" "demo" {
  bucket = "my-terraform-jenkins-demo-987654321"
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "sourabh-demo-bucket-2026-12345"

  tags = {
    Name        = "MyS3Bucket"
    Environment = "Dev"
  }
}
