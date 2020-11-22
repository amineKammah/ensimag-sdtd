import os
import random
from typing import Generator, List

from kafka import KafkaAdminClient, KafkaConsumer, KafkaProducer
from kafka.admin import NewTopic


class KafkaAgent:
    def __init__(self, kafka_servers: List[str]) -> None:
        self.kafka_servers = kafka_servers
        self.kafka_producer = KafkaProducer(bootstrap_servers=self.kafka_servers)

    def create_topic(self, kafka_topic: str, error_if_exists: bool = False):
        if not error_if_exists:
            existing_topics = KafkaConsumer(
                bootstrap_servers=self.kafka_servers
            ).topics()
            if kafka_topic in existing_topics:
                print(f"Failed to create topic, topic '{kafka_topic}' already exists.")
                return

        admin = KafkaAdminClient(bootstrap_servers=self.kafka_servers)

        topic = NewTopic(name=kafka_topic, num_partitions=1, replication_factor=1)
        admin.create_topics([topic])

    def consumer(
        self, kafka_topic: str, timeout_ms: int, auto_offset_reset: str = "latest"
    ) -> KafkaConsumer:
        kafka_consumer = KafkaConsumer(
            bootstrap_servers=self.kafka_servers,
            consumer_timeout_ms=timeout_ms,
            auto_offset_reset=auto_offset_reset,
        )
        kafka_consumer.subscribe([kafka_topic])

        return kafka_consumer

    def batch_consumer(
        self, kafka_topic: str, batch_size: int = 100, timeout_ms: int = 1_000
    ) -> Generator[List, None, None]:
        kafka_consumer = self.consumer(kafka_topic, timeout_ms)

        while True:
            images = [event for _, event in zip(range(batch_size), kafka_consumer)]
            yield images

    def produce(self, kafka_topic: str, data: List) -> None:
        for value in data:
            self.kafka_producer.send(kafka_topic, value=bytes(value, "utf-8"))

    def random_producer(self, kafka_topic: str, k: int, seed: int = 0) -> None:
        test_data_path = "test_data/how_to_win_argments/"
        dateset = os.listdir(test_data_path)

        random.seed(seed)
        images = random.choices(dateset, k=k)
        images_full_path = [
            "test_data/how_to_win_argments/" + image for image in images
        ]
        self.produce(kafka_topic, images_full_path)
