import os
import random

from kafka import KafkaProducer


class Producer:
    def __init__(self, kafka_server: str, kafka_topic: str) -> None:
        test_data_path = "ensimag-sdtd/test_data/how_to_win_argments/"
        self.dateset = os.listdir(test_data_path)
        self.kafka_topic = kafka_topic
        self.kafka_producer = KafkaProducer(bootstrap_servers=kafka_server)

    def random_producer(self, k: int) -> None:
        """
        Send k random images
        """
        images = random.choices(self.dateset, k=k)

        for image in images:
            self.kafka_producer.send(self.kafka_topic, value=image)


from kafka import KafkaAdminClient
from kafka.admin import NewTopic

admin = KafkaAdminClient(bootstrap_servers='localhost:9092')

topic = NewTopic(name='my-topic',
                 num_partitions=1,
                 replication_factor=1)
admin.create_topics([topic])



