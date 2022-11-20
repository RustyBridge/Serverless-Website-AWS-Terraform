terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region                  = var.profile_d[0].region
  shared_credentials_files = ["C:/Users/George/.aws/credentials"]
  profile                 = var.profile_d[0].name
}




# Create S3 bucket for "gvasilopoulos.xyz"
resource "aws_s3_bucket" "b1" {
  bucket = "tf-s3-website.gvasilopoulos.xyz"
}

# Create S3 bucket for "www.gvasilopoulos.xyz"
resource "aws_s3_bucket" "b2" {
  bucket = "tf-s3-website.www.gvasilopoulos.xyz"
}

# Create Public-Read ACL for S3 buckets
resource "aws_s3_bucket_acl" "mybucketacl" {
  bucket = [
    aws_s3_bucket.b1.id,
    aws_s3_bucker.b2.id
  ]
  acl = "public-read"
}

# Create server side encryption key for buckets
resource "aws_kms_key" "bucketkey" {
  description = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

# Enable server side encryption for buckets
resource "aws_s3_bucket_server_side_encryption_configuration" "myencconfig" {
  bucket = [
    aws_s3_bucket.b1.bucket,
    aws_s3_bucker.b2.bucket
  ]

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.bucketkey.arn
      sse_algorithm     = "aws:kms"
  }
 }
}
# Attach S3 Bucket Policy to Allow Public Read
resource "aws_s3_bucket_policy" "AllowPublicRead" {
  bucket = [
    aws_s3_bucket.b1.id,
    aws_s3_bucker.b2.id
  ]
  policy = data.aws_iam_policy_document.AllowPublicRead.json
}

# Create S3 Bucket Policy to Allow Public Read
data "aws_iam_policy_document" "AllowPublicRead" {
  statement  {
    sid = "AllowPublicRead"
    effect = "Allow"
    actions = "s3:GetObject"
    principals {
        type = "*"
        identifiers = "*"
    }
    resources = [
        aws_s3_bucket.b1.arn,
        "${aws_s3_bucker.b1.arn}/*",
        aws_s3_bucket.b2.arn,
        "${aws_s3_bucker.b2.arn}/*"
    ]
  }
}

# Configure "tf-s3-website.gvasilopoulos.xyz" bucket for website hosting
resource "aws_s3_bucket_website_configuration" "mybucketwebconfig1" {
  bucket = aws_s3_bucket.b1.bucket

  index_document {
    suffix = "index.html"
  }
}

# Configure "tf-s3-website.www.gvasilopoulos.xyz" bucket to redirect web trafic to "tf-s3-website.gvasilopoulos.xyz"
resource "aws_s3_bucket_website_configuration" "mybucketwebconfig2" {
  bucket = aws_s3_bucket.b2.bucket

  redirect_all_requests_to {
    hostname = "gvasilopoulos.xyz"
    protocol = "https"
  }
}

# 