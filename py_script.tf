# Create a python script that reads the table value - API2
resource "local_file" "r_vcounter_py" {
  filename = "r_vcounter.py"
  depends_on = [aws_dynamodb_table.tf_db]
  content = <<-EOF
import json, boto3

client = boto3.client('dynamodb')
TableName = '${aws_dynamodb_table.tf_db.id}'

def lambda_handler(event, context):
    
    data = client.get_item(
        TableName='${aws_dynamodb_table.tf_db.id}',
        Key = {
            'vcounter': {'S': 'view-count'}
        }
    )
    
    data1 = data['Item']['Quantity']['N']
    
    
    return {      
            'statusCode': 200,
            'body': data1}
            EOF
  }

# Create python script that increments the table value - API1
resource "local_file" "vcounter_py" {
  filename = "vcounter.py"
  depends_on = [aws_dynamodb_table.tf_db]
  content = <<-EOF
import json, boto3

client = boto3.client('dynamodb')
TableName = '${aws_dynamodb_table.tf_db.id}'

def lambda_handler(event, context):
    
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

# Archive the files - Ready them for upload

data "archive_file" "vcounter" {
  type = "zip"
  source_file = "${path.module}/vcounter.py"
  output_path = "${path.module}/vcounter.zip"
  depends_on = [local_file.vcounter_py]
}

data "archive_file" "r_vcounter" {
  type = "zip"
  source_file = "${path.module}/r_vcounter.py"
  output_path = "${path.module}/r_vcounter.zip"
  depends_on = [local_file.r_vcounter_py]
}
