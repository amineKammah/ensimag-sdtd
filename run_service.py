from data_processing.ocr_service import OCRService

from messaging_agent.kafka_agent import KafkaAgent


kafka_servers = ['a04ea17a4263d4e8f9aaecdc8b1b5ed3-1962944993.us-east-1.elb.amazonaws.com:9092', 'ab6dd523e279d4d2bb3a60d1ae32fdee-166896499.us-east-1.elb.amazonaws.com:9092']

zoo_servers = ['a0efe17d6231542d1a3b0701d747e315-1175272134.us-east-1.elb.amazonaws.com:2181', 'a112424ef425a4120bdb1866e2e1192d-925634392.us-east-1.elb.amazonaws.com:2181']

k8s_master = 'k8s://https://10.0.0.127:6443'

images_feed_topic = 'images_feed'

text_feed_topic = 'text_feed'


def start_service():
    kafka_agent = KafkaAgent(kafka_servers)
    kafka_agent.create_topic(images_feed_topic)
    kafka_agent.create_topic(text_feed_topic)

    OCRService(zoo_servers, kafka_servers, k8s_master, images_feed_topic, text_feed_topic).start()

