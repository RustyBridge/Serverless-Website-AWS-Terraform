## Create HTTP API1 - read visitor counter lambda
resource "aws_apigatewayv2_api" "tf_vcounter_api1" {
  name = "tf_r_vcounter_api"
  protocol_type = "HTTP"
  disable_execute_api_endpoint = true
  target = aws_lambda_function.tf_read_v_counter.arn
  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST"]
    allow_credentials = false
  }
}

# Create HTTP API2 - increment visitor counter lambda
resource "aws_apigatewayv2_api" "tf_vcounter_api2" {
  name = "tf_i_vcounter_api"
  protocol_type = "HTTP"
  disable_execute_api_endpoint = true
  target = aws_lambda_function.tf_increment_v_counter.arn
  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST"]
    allow_credentials = false
  }
}

# Create custom domain name for the HTTP APIs
resource "aws_apigatewayv2_domain_name" "tf_api_dn" {
  domain_name = "api.gvasilopoulos.xyz"
  domain_name_configuration {
    certificate_arn = "arn:aws:acm:us-east-1:786880879176:certificate/bdab6c9b-29a3-453f-bab2-021e2b292c92"
    endpoint_type = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

# Create Permission to allow API1 to invoke read visitor counter Lambda
resource "aws_lambda_permission" "tf_lp1" {
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.tf_read_v_counter.function_name
  principal = "apigateway.amazonaws.com"
  statement_id = "AllowExecutionFromAPIGateway"

  source_arn = "${aws_apigatewayv2_api.tf_vcounter_api1.execution_arn}/*/*"
}


# Create Permission to allow API2 to invoke increment visitor counter Lambda
resource "aws_lambda_permission" "tf_lp2" {
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.tf_increment_v_counter.function_name
  principal = "apigateway.amazonaws.com"
  statement_id = "AllowExecutionFromAPIGateway"

  source_arn = "${aws_apigatewayv2_api.tf_vcounter_api2.execution_arn}/*/*"
}

# Create a mapping for the API1 to the Custom Domain Name
resource "aws_apigatewayv2_api_mapping" "tf_api_map1" {
  api_id = aws_apigatewayv2_api.tf_vcounter_api1.id
  domain_name = aws_apigatewayv2_domain_name.tf_api_dn.id
  stage = "$default"
  api_mapping_key = "AP1"
  
  depends_on = [aws_apigatewayv2_api.tf_vcounter_api1]
}

# Create a mapping for the API2 to the Custom Domain Name
resource "aws_apigatewayv2_api_mapping" "tf_api_map2" {
  api_id = aws_apigatewayv2_api.tf_vcounter_api2.id
  domain_name = aws_apigatewayv2_domain_name.tf_api_dn.id
  stage = "$default"
  api_mapping_key = "AP2"
  
  depends_on = [aws_apigatewayv2_api.tf_vcounter_api2]
}