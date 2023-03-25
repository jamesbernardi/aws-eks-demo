resource "random_string" "name" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_s3_bucket" "backup" {
  bucket = "${var.bucket}-${random_string.name.result}"
}

resource "aws_s3_bucket_acl" "backup" {
  bucket = aws_s3_bucket.backup.id
  acl    = "private"
}

resource "aws_s3_bucket_lifecycle_configuration" "backup" {
  bucket = aws_s3_bucket.backup.id
  rule {
    id = "expiration"
    expiration {
      days = 90
    }
    status = "Enabled"
  }
}
