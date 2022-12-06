import json, boto3

client = boto3.client('dynamodb')
TableName = 'tf-db'

def lambda_handler(event, context):
    
    #data['Item']['Quantity']['N'] = str(int(data['Item']['Quantity']['N']) + 1)
    
    response = client.update_item(
        TableName='tf-db',
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
