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