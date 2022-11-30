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