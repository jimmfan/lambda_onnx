import boto3

dynamodb = boto3.resource('dynamodb')
orders_table = dynamodb.Table('Orders')

def lambda_handler(event, context):
    # Extract necessary data from event
    order_id = event['order_id']
    order_data = event['order_data']

    # Check if the order already exists in DynamoDB
    existing_order = get_order(order_id)
    if existing_order:
        # If order already exists, update it
        update_order(order_id, order_data)
        response = {'message': 'Order updated successfully'}
    else:
        # If order does not exist, put it
        put_order(order_id, order_data)
        response = {'message': 'Order added successfully'}

    return response

def get_order(order_id):
    # Get an order item from DynamoDB by order_id
    try:
        response = orders_table.get_item(
            Key={
                'OrderId': order_id
            }
        )
        return response.get('Item')
    except Exception as e:
        print(f"Failed to get order: {e}")
        return None

def put_order(order_id, order_data):
    # Add a new order item to DynamoDB
    try:
        orders_table.put_item(
            Item={
                'OrderId': order_id,
                'OrderData': order_data
            }
        )
    except Exception as e:
        print(f"Failed to put order: {e}")

    

def update_order(order_id, order_data):
    # Update an existing order item in DynamoDB
    try:
        orders_table.update_item(
            Key={
                'OrderId': order_id
            },
            UpdateExpression='SET #data = :order_data',
            ExpressionAttributeNames={
                '#data': 'OrderData'
            },
            ExpressionAttributeValues={
                ':order_data': order_data
            }
        )
    except Exception as e:
        print(f"Failed to update order: {e}")

def put_item(id, complaints):
    try:
        response = orders_table.put_item(
            Item={
                'id': id,
                'complaints': complaints,
            },
            ConditionExpression='attribute_not_exists(id) and (attribute_not_exists(complaints) or not contains(complaints, :complaints))',
            ExpressionAttributeValues={
                ':complaints': complaints,
            }
        )
        return {"message": f"Item with id {id} added to table"}

    except Exception as e:
        return {"message": f"Error: {e}"}