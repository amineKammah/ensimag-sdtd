from pyspark import SparkContext

from messaging_agent.kafka_consumer import Consumer

from data_processing.optical_character_recognizer import OpticalCharacterRecognizer


class OCRService:
    def __init__(self, kafka_server: str, kafka_topic: str, distribution_threshold: int = 50):
        self.distribution_threshold = distribution_threshold
        self.kafka_server = kafka_server
        self.kafka_topic = kafka_topic

    def distributed_extract(self, images):
        sc = SparkContext("local", "first app")
        sc.addPyFile('/ensimag-sdtd/data_processing/optical_character_recognizer.py')
        from data_processing.optical_character_recognizer import OpticalCharacterRecognizer

        return sc.parallelize(images).map(lambda image: OpticalCharacterRecognizer.extract(image)).collect()

    def parallelized_extract(self, images) -> List:
        return list(images.map(lambda image: OpticalCharacterRecognizer.extract(image)))

    def start(self) -> None:
        kafka_consumer = Consumer(self.kafka_server, self.kafka_topic)

        # TODO: Add exception handling
        for batch in kafka_consumer.batch_consumer():
            images = self.prep_batch(batch)

            if len(batch) > self.distribution_threshold:
                extracted_text = self.distributed_extract(images)
            else:
                extracted_text = self.parallelized_extract(images)

            print(extracted_text)

    def prep_batch(self, batch) -> List:
        pass