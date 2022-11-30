# Create a Cloudfront Distribution for bucket-origin

resource "aws_cloudfront_distribution" "s3_distribution" {
  enabled = true
  aliases = ["gvasilopoulos.xyz", "www.gvasilopoulos.xyz"]
  price_class = "PriceClass_100"
  is_ipv6_enabled = true
  depends_on = [aws_s3_bucket.b1]
  
  default_cache_behavior {
    allowed_methods = ["GET", "HEAD"]
    cached_methods = ["GET", "HEAD"]
    target_origin_id = "www.gvasilopoulos.xyz"
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
    domain_name = "${aws_aws_s3_bucket.b1.bucket}.s3-website-us-east-1.amazon.com"
    origin_id = "www.gvasilopoulos.xyz"
  }
}