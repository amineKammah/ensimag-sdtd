from kafka import KafkaConsumer


class Consumer:
    def __init__(self, kafka_server: str, kafka_topic: str) -> None:
        self.kafka_topic = kafka_topic
        self.kafka_server = kafka_server

    def batch_consumer(self, batch_size: int = 100, timeout_ms: int = 1_000) -> None:

        kafka_consumer = KafkaConsumer(bootstrap_servers=self.kafka_server, consumer_timeout_ms=timeout_ms)
        kafka_consumer.subscribe([self.kafka_topic])

        while True:
            images = [event for _, event in zip(range(batch_size), kafka_consumer)]
            yield images