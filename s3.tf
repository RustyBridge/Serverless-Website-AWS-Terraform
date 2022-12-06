# Create S3 bucket for "gvasilopoulos.xyz"
resource "aws_s3_bucket" "b1" {
  bucket = "gvasilopoulos.xyz"
  force_destroy = true 
}

# Create Public-Read ACL for S3 bucket
resource "aws_s3_bucket_acl" "mybucketacl1" {
  bucket = aws_s3_bucket.b1.id
  acl = "public-read"
}

# Enable server side encryption for bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "myencconfig1" {
  bucket = aws_s3_bucket.b1.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
  }
 }
}

# Attach S3 Bucket Policy to Allow Public Read
resource "aws_s3_bucket_policy" "AllowPublicRead1" {
  bucket = aws_s3_bucket.b1.id
  policy = data.aws_iam_policy_document.AllowPublicRead1.json
}

# Create S3 Bucket Policy to Allow Public Read
data "aws_iam_policy_document" "AllowPublicRead1" {
  statement  {
    sid = "AllowPublicRead1"
    effect = "Allow"
    actions = ["s3:GetObject"]
    principals {
        type = "*"
        identifiers = ["*"]
    }
        resources = [
          "${aws_s3_bucket.b1.arn}",
          "${aws_s3_bucket.b1.arn}/*"
    ]
  }
}

# Configure "gvasilopoulos.xyz" bucket for website hosting
resource "aws_s3_bucket_website_configuration" "mybucketwebconfig1" {
  bucket = aws_s3_bucket.b1.bucket

  index_document {
    suffix = "index.html"
  }
}
