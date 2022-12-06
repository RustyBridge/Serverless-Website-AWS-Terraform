# Create Lamda function for increment visitor counter python script - API1
resource "aws_lambda_function" "tf_increment_v_counter" {
  function_name = "tf_increment_v_counter"
  role = "${aws_iam_role.tf_lamda_role.arn}"
  description = "Reads the visitor count value from the DB, increments it by 1 and returns the result"
  filename = "${path.module}/vcounter.zip"
  handler = "vcounter.lambda_handler"
  runtime = "python3.9"
  depends_on = [data.archive_file.vcounter]
}

# Create Lamda function for increment visitor counter python script - API2
resource "aws_lambda_function" "tf_read_v_counter" {
  function_name = "tf_read_v_counter"
  role = "${aws_iam_role.tf_lamda_role.arn}"
  description = "Reads the visitor count value from the DB and returns the result"
  filename = "${path.module}/r_vcounter.zip"
  handler = "r_vcounter.lambda_handler"
  runtime = "python3.9"
  depends_on = [data.archive_file.r_vcounter]
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