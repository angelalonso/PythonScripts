import boto3
import json
import time

region_name = 'eu-west-1'
queue_src = 'INFRA-2172_TEST_sender'
queue_dst = 'INFRA-2172_TEST_receiver'
queue_dst_url = 'https://sqs.eu-west-1.amazonaws.com/906315958670/INFRA-2172_TEST_receiver'

max_queue_messages = 1
message_bodies = []

sqs_src = boto3.resource('sqs', region_name=region_name)
sqs_dst = boto3.resource('sqs', region_name=region_name)

queue_src = sqs_src.get_queue_by_name(QueueName=queue_src)
queue_dst = sqs_dst.get_queue_by_name(QueueName=queue_dst)
def main():
    result = []
    go_on = True
    while go_on:
        partial_result = []
        for message in queue_src.receive_messages(MaxNumberOfMessages=max_queue_messages, MessageAttributeNames=['All']):
            #time.sleep(1)
            response = queue_dst.send_message(
                QueueUrl=queue_dst_url,
                DelaySeconds=1,
                MessageAttributes=message.message_attributes,
                MessageBody=(
                    message.body
                )
            )
            message.delete()
            partial_result.append(response['MessageId'])
        if len(partial_result) == 0:
            go_on = False
        result.append(partial_result)
    return result

print(main())
