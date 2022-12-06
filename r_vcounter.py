import json, boto3

client = boto3.client('dynamodb')
TableName = 'tf-db'

def lambda_handler(event, context):
    
    data = client.get_item(
        TableName='tf-db',
        Key = {
            'vcounter': {'S': 'view-count'}
        }
    )
    
    data1 = data['Item']['Quantity']['N']
    
    
    return {      
            'statusCode': 200,
            'body': data1}
