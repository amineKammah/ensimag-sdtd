import os

from data_processing.ocr_service import OCRService
from messaging_agent.kafka_agent import KafkaAgent


def start_service():
    kafka_servers = [os.environ.get("KAFKA_SERVER1"), os.environ.get("KAFKA_SERVER2")]

    zoo_servers = [os.environ.get("ZK_SERVER1"), os.environ.get("ZK_SERVER2")]

    k8s_master = os.environ.get("K8S_MASTER")

    images_feed_topic = "images_feed"

    text_feed_topic = "text_feed"

    kafka_agent = KafkaAgent(kafka_servers)
    kafka_agent.create_topic(images_feed_topic)
    kafka_agent.create_topic(text_feed_topic)

    OCRService(
        zoo_servers, kafka_servers, k8s_master, images_feed_topic, text_feed_topic
    ).start()


if __name__ == "__main__":
    start_service()
