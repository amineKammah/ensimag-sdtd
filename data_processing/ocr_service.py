from typing import List

from pyspark import SparkContext
from pyspark.streaming import StreamingContext
from pyspark.streaming.kafka import KafkaUtils

from messaging_agent.kafka_agent import KafkaAgent

from data_processing.optical_character_recognizer import OpticalCharacterRecognizer


class OCRService:
    def __init__(self, kafka_server: str, consumer_topic: str, producer_topic: str, distribution_threshold: int = 30):
        self.distribution_threshold = distribution_threshold
        self.kafka_server = kafka_server
        self.kafka_agent = KafkaAgent(kafka_server)
        self.consumer_topic = consumer_topic
        self.producer_topic = producer_topic


    @staticmethod
    def _distributed_extract(images):
        sc = SparkContext("local", "first app")
        sc.addPyFile('/ensimag-sdtd/data_processing/optical_character_recognizer.py')
        from data_processing.optical_character_recognizer import OpticalCharacterRecognizer

        return sc.parallelize(images).map(lambda image: OpticalCharacterRecognizer.extract(image)).collect()

    @staticmethod
    def _parallelized_extract(images) -> List:
        return list(map(lambda image: OpticalCharacterRecognizer.extract(image), images))

    @staticmethod
    def _process_event(event, agent, topic):
        image = event.value.decode("utf-8")
        extracted_text = OpticalCharacterRecognizer.extract(image)

        agent.produce(topic, [extracted_text])
        return extracted_text


    def start(self) -> None:
        sc = SparkContext("local", "first app")
        sc.addPyFile('/ensimag-sdtd/data_processing/optical_character_recognizer.py')
        from data_processing.optical_character_recognizer import OpticalCharacterRecognizer

        ssc = StreamingContext(sc, 2)
        kvs = KafkaUtils.createStream(ssc, self.kafka_server, "event-consumer", {self.consumer_topic:1})

        kvs.map(lambda event: OCRService._process_event(event, self.kafka_agent, self.producer_topic)).collect()

        ssc.start()
        ssc.awaitTermination()

    @staticmethod
    def _prep_input_batch(batch) -> List:
        return list(map(lambda value: value.value.decode("utf-8"), batch))
