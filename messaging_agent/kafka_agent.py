import os
from typing import Generator, List
import random

from kafka import KafkaProducer, KafkaAdminClient, KafkaConsumer
from kafka.admin import NewTopic


class KafkaAgent:
    def __init__(self, kafka_server: str) -> None:
        self.kafka_server = kafka_server
        self.kafka_producer = KafkaProducer(bootstrap_servers=self.kafka_server)

    def create_topic(self, kafka_topic: str):
        admin = KafkaAdminClient(bootstrap_servers=self.kafka_server)

        topic = NewTopic(name=kafka_topic,
                         num_partitions=1,
                         replication_factor=1)
        admin.create_topics([topic])

    def consumer(self, kafka_topic: str, timeout_ms: int) -> KafkaConsumer:
        kafka_consumer = KafkaConsumer(bootstrap_servers=self.kafka_server, consumer_timeout_ms=timeout_ms)
        kafka_consumer.subscribe([kafka_topic])

        return kafka_consumer

    def batch_consumer(self, kafka_topic: str, batch_size: int = 100, timeout_ms: int = 1_000) -> Generator[List, None, None]:
        kafka_consumer = self.consumer(kafka_topic, timeout_ms)

        while True:
            images = [event for _, event in zip(range(batch_size), kafka_consumer)]
            yield images

    def produce(self, kafka_topic: str, data: List) -> None:
        for value in data:
            self.kafka_producer.send(kafka_topic, value=bytes(value, "utf-8"))

    def random_producer(self, kafka_topic: str, k: int) -> None:
        test_data_path = "test_data/how_to_win_argments/"
        dateset = os.listdir(test_data_path)

        images = random.choices(dateset, k=k)
        self.produce(kafka_topic, images)
