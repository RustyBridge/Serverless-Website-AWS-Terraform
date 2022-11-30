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
  force_destroy = true 
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

# Configure "www.gvasilopoulos.xyz" bucket for website hosting
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
  name = "www.gvasilopoulos.xyz"
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
  name = "www.gvasilopoulos.xyz"
  type = "AAAA"
  allow_overwrite = true
   alias {
      name                   = aws_apigatewayv2_domain_name.tf_api_dn.domain_name_configuration[0].target_domain_name
      zone_id                = aws_apigatewayv2_domain_name.tf_api_dn.domain_name_configuration[0].hosted_zone_id
      evaluate_target_health = false
  }
}

# Create DynamoDB table for visitor counter
resource "aws_dynamodb_table" "tf_db" {
  name = "tf-db"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "vcounter"

  attribute {
    name = "vcounter"
    type = "S"
  }
}

# Create DynamoDB table item for visitor counter
resource "aws_dynamodb_table_item" "view-count" {
  table_name = aws_dynamodb_table.tf_db.name
  hash_key = aws_dynamodb_table.tf_db.hash_key

  item = <<ITEM
  {
    "vcounter": {"S": "view-count"},
    "Quantity": {"N": "0"}
  }
ITEM
}

# Create python script that points to the DDB and zip it
resource "local_file" "vcounter_py" {
  filename = "vcounter.py"
  depends_on = [aws_dynamodb_table.tf_db]
  content = <<-EOF
import json, boto3

client = boto3.client('dynamodb')
TableName = '${aws_dynamodb_table.tf_db.id}'

def lambda_handler(event, context):
    
    '''
    data = client.get_item(
        TableName='${aws_dynamodb_table.tf_db.id}',
        Key = {
            'vcounter': {'S': 'view-count'}
        }
    )
    '''
    
    #data['Item']['Quantity']['N'] = str(int(data['Item']['Quantity']['N']) + 1)
    
    response = client.update_item(
        TableName='${aws_dynamodb_table.tf_db.id}',
        Key = {
            'vcounter': {'S': 'view-count'}
        },
        UpdateExpression = 'ADD Quantity :inc',
        ExpressionAttributeValues = {":inc" : {"N": "1"}},
        ReturnValues = 'UPDATED_NEW'
        )
        
    value = response['Attributes']['Quantity']['N']
    
    return {      
            'statusCode': 200,
            'body': value}
            EOF
}

data "archive_file" "vcounter" {
  type = "zip"
  source_file = "${path.module}/vcounter.py"
  output_path = "${path.module}/vcounter.zip"
  depends_on = [local_file.vcounter_py]
}

# Create Lamda function for visitor counter python script
resource "aws_lambda_function" "tf_increment_v_counter" {
  function_name = "tf_increment_v_counter"
  role = "${aws_iam_role.tf_lamda_role.arn}"
  description = "Reads the visitor count value from the DB, increments it by 1 and returns the result"
  filename = "${path.module}/vcounter.zip"
  handler = "vcounter.lambda_handler"
  runtime = "python3.9"
  depends_on = [data.archive_file.vcounter]
}

# Create IAM Role for Lamda access to DDB, S3
resource "aws_iam_role" "tf_lamda_role" {
  name = "tf_lamda_role"
  description = "grants lamda full access to DynamoDB, S3 and basic exec"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Attach the required policies to the role
resource "aws_iam_role_policy_attachment" "tf_lamda_roles_policies" {
  role = "${aws_iam_role.tf_lamda_role.name}"
  count = "${length(var.iam_policy_arn)}"
  policy_arn = "${var.iam_policy_arn[count.index]}"
}

# Create HTTP API
resource "aws_apigatewayv2_api" "tf_vcounter_api" {
  name = "tf_vcounter_api"
  protocol_type = "HTTP"
  disable_execute_api_endpoint = true
  target = aws_lambda_function.tf_increment_v_counter.arn
  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST"]
    allow_credentials = false
  }
}

# Create and associate custom domain name with HTTP API
resource "aws_apigatewayv2_domain_name" "tf_api_dn" {
  domain_name = "api.gvasilopoulos.xyz"
  domain_name_configuration {
    certificate_arn = "arn:aws:acm:us-east-1:786880879176:certificate/bdab6c9b-29a3-453f-bab2-021e2b292c92"
    endpoint_type = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

# Create Permission to allow Lambda invokation from the API
resource "aws_lambda_permission" "tf_lp" {
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.tf_increment_v_counter.function_name
  principal = "apigateway.amazonaws.com"
  statement_id = "AllowExecutionFromAPIGateway"

  source_arn = "${aws_apigatewayv2_api.tf_vcounter_api.execution_arn}/*/*"
}

# Create a mapping for the API to the Custom Domain Name
resource "aws_apigatewayv2_api_mapping" "tf_api_map" {
  api_id = aws_apigatewayv2_api.tf_vcounter_api.id
  domain_name = aws_apigatewayv2_domain_name.tf_api_dn.id
  stage = "${aws_apigatewayv2_api.tf_vcounter_api.api_endpoint}/default"
  
  depends_on = [aws_apigatewayv2_api.tf_vcounter_api]
}