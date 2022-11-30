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
  records = ["_6b0085561405f21bd10f6c8c88a7b067.yzdtlljtvc.acm-validations.aws."]
  allow_overwrite = false
}


# Create IPv4 and IPv6 records for "gvasilopoulos.xyz"
resource "aws_route53_record" "A1" {
  zone_id = aws_route53_zone.tfzone.zone_id
  name = "gvasilopoulos.xyz"
  type = "A"
  allow_overwrite = true
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
  allow_overwrite = true
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
  allow_overwrite = true
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
  allow_overwrite = true
   alias {
      name                   = aws_cloudfront_distribution.s3_distribution.domain_name
      zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
      evaluate_target_health = true
  }
}

# Create IPv4 and IPv6 records for API Gateway Custom Domain name
resource "aws_route53_record" "A3" {
  zone_id = aws_route53_zone.tfzone.zone_id
  name = "api.gvasilopoulos.xyz"
  type = "A"
  allow_overwrite = true
   alias {
      name                   = aws_apigatewayv2_domain_name.tf_api_dn.domain_name_configuration[0].target_domain_name
      zone_id                = aws_apigatewayv2_domain_name.tf_api_dn.domain_name_configuration[0].hosted_zone_id
      evaluate_target_health = false
  }
}

resource "aws_route53_record" "AAAA3" {
  zone_id = aws_route53_zone.tfzone.zone_id
  name = "api.gvasilopoulos.xyz"
  type = "AAAA"
  allow_overwrite = true
   alias {
      name                   = aws_apigatewayv2_domain_name.tf_api_dn.domain_name_configuration[0].target_domain_name
      zone_id                = aws_apigatewayv2_domain_name.tf_api_dn.domain_name_configuration[0].hosted_zone_id
      evaluate_target_health = false
  }
}