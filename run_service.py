from data_processing.ocr_service import OCRService

from messaging_agent.kafka_agent import KafkaAgent


kafka_servers = ['a9e0ef99fcead4ebe9122a496422aa6f-378095093.us-east-1.elb.amazonaws.com:9092', 'a43ef7bfc575243f799608504380c04b-1947443702.us-east-1.elb.amazonaws.com:9092']

zoo_servers = ['a41303edcb4fb4b9a87e57a5cc20a5c1-932356733.us-east-1.elb.amazonaws.com:2181', 'a21296358ce54483dbc8aee84cb6bf37-639466589.us-east-1.elb.amazonaws.com:2181']

k8s_master = 'k8s://https://10.0.0.127:6443'

images_feed_topic = 'images_feed'

text_feed_topic = 'text_feed'


def start_service():
    kafka_agent = KafkaAgent(kafka_servers)
    kafka_agent.create_topic(images_feed_topic)
    kafka_agent.create_topic(text_feed_topic)

    OCRService(zoo_servers, kafka_servers, k8s_master, images_feed_topic, text_feed_topic).start()


if __name__ == "__main__":
    start_service()
