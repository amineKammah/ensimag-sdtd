import os
import random

from kafka import KafkaProducer


class Producer:
    def __init__(self) -> None:
        test_data_path = "ensimag-sdtd/test_data/how_to_win_argments/"
        self.dateset = os.listdir(test_data_path)
        self.kafka_producer = KafkaProducer(bootstrap_servers=['broker1:1234'])

    def produce(self, k: int) -> None:
        images = random.choices(self.dateset, k=k)
