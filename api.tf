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
  stage = "$default"
  
  depends_on = [aws_apigatewayv2_api.tf_vcounter_api]
}