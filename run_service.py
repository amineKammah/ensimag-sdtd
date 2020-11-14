from data_processing.ocr_service import OCRService

from messaging_agent.kafka_agent import KafkaAgent


kafka_servers = ['a66bada9889d546fc93b8397608ec0ff-1158322397.us-east-1.elb.amazonaws.com:9092', 'afa4e9850969f4f7c8dba09a6bb42602-1735669284.us-east-1.elb.amazonaws.com:9092']

zoo_servers = ['adc4fe8324e59401ba85a5c3e35b3236-1459396048.us-east-1.elb.amazonaws.com:2181', 'ae1a6723087fa4f80b4058c82206c818-630604259.us-east-1.elb.amazonaws.com:2181']

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
