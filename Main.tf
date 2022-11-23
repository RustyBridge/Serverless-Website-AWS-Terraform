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



# Create S3 bucket for "www.gvasilopoulos.xyz"
resource "aws_s3_bucket" "b1" {
  bucket = "www.gvasilopoulos.xyz"
}

# Create Public-Read ACL for S3 bucket
resource "aws_s3_bucket_acl" "mybucketacl1" {
  bucket = aws_s3_bucket.b1.id
  acl = "public-read"
}

# Create server side encryption key for bucket
resource "aws_kms_key" "bucketkey" {
  description = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

# Enable server side encryption for bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "myencconfig1" {
  bucket = aws_s3_bucket.b1.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.bucketkey.arn
      sse_algorithm     = "aws:kms"
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

# Configure "tf-s3-website.www.gvasilopoulos.xyz" bucket for website hosting
resource "aws_s3_bucket_website_configuration" "mybucketwebconfig1" {
  bucket = aws_s3_bucket.b1.bucket

  index_document {
    suffix = "index.html"
  }
}

# Create a Cloudfront Distribution for bucket-origin

resource "aws_cloudfront_distribution" "s3_distribution" {
  enabled = true
  aliases = ["gvasilopoulos.xyz", "www.gvasilopoulos.xyz"]
  price_class = "PriceClass_100"
  is_ipv6_enabled = true
  
  default_cache_behavior {
    allowed_methods = ["GET", "HEAD"]
    cached_methods = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.b1.bucket
    viewer_protocol_policy = "redirect-to-https"
    compress = true
    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  
  viewer_certificate {
    acm_certificate_arn = "arn:aws:acm:us-east-1:786880879176:certificate/bdab6c9b-29a3-453f-bab2-021e2b292c92"
    ssl_support_method = "sni-only"
    minimum_protocol_version = "TLSv1.2_2019"
  }
  
  origin {
    domain_name = aws_s3_bucket.b1.bucket_regional_domain_name
    origin_id = "tf-s3-website.www.gvasilopoulos.xyz"
  }
}

# Create a resource to import the Route53 hosted zone 
resource "aws_route53_zone" "tfzone" {
  name = "gvasilopoulos.xyz"
  force_destroy = false
}

# Create a resource to import the SSL Certificate CNAME record
resource "aws_route53_record" "sslrecord" {
  zone_id = aws_route53_zone.tfzone.zone_id
  name = "_025b38c79fec4976fe17c1742f66cd9c"
  type = "CNAME"
  ttl = 300
  records = [ ]
}


# Create IPv4 and IPv6 records for "gvasilopoulos.xyz"
resource "aws_route53_record" "A1" {
  zone_id = aws_route53_zone.tfzone.zone_id
  name = "gvasilopoulos.xyz"
  type = "A"
    alias {
      name                   = aws_cloudfront_distribution.s3_distribution.domain_name
      zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
      evaluate_target_health = true
  }
}

resource "aws_route53_record" "AAAA1" {
  zone_id = aws_route53_zone.tfzone.zone_id
  name = "gvasilopoulos.xyz"
  type = "AAAA"
   alias {
      name                   = aws_cloudfront_distribution.s3_distribution.domain_name
      zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
      evaluate_target_health = true
  }
}

# Create IPv4 and IPv6 records for "www.gvasilopoulos.xyz"
resource "aws_route53_record" "A2" {
  zone_id = aws_route53_zone.tfzone.zone_id
  name = "www.gvasilopoulos.xyz"
  type = "A"
   alias {
      name                   = aws_cloudfront_distribution.s3_distribution.domain_name
      zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
      evaluate_target_health = true
  }
}

resource "aws_route53_record" "AAAA2" {
  zone_id = aws_route53_zone.tfzone.zone_id
  name = "www.gvasilopoulos.xyz"
  type = "AAAA"
   alias {
      name                   = aws_cloudfront_distribution.s3_distribution.domain_name
      zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
      evaluate_target_health = true
  }
}

