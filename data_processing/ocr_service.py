from pyspark import SparkContext

from messaging_agent.kafka_agent import KafkaAgent

from data_processing.optical_character_recognizer import OpticalCharacterRecognizer


class OCRService:
    def __init__(self, kafka_server: str, consumer_topic: str, producer_topic: str, distribution_threshold: int = 30):
        self.distribution_threshold = distribution_threshold
        self.kafka_agent = KafkaAgent(kafka_server)
        self.consumer_topic = consumer_topic


    @staticmethod
    def _distributed_extract(images):
        sc = SparkContext("local", "first app")
        sc.addPyFile('/ensimag-sdtd/data_processing/optical_character_recognizer.py')
        from data_processing.optical_character_recognizer import OpticalCharacterRecognizer

        return sc.parallelize(images).map(lambda image: OpticalCharacterRecognizer.extract(image)).collect()

    @staticmethod
    def _parallelized_extract(images) -> List:
        return list(map(lambda image: OpticalCharacterRecognizer.extract(image), images))

    def start(self) -> None:

        # TODO: Add exception handling
        for batch in self.kafka_agent.batch_consumer(self.consumer_topic):

            images = self._prep_batch(batch)
            if images:
                if len(batch) > self.distribution_threshold:
                    extracted_text = self._distributed_extract(images)
                else:
                    extracted_text = self._parallelized_extract(images)

            # Resend using Kafka
            kafka_agent.produce(self.producer_topic, self._prep_output_batch(extracted_text))

    @staticmethod
    def _prep_input_batch(batch) -> List:
        return batch

    @staticmethod
    def _prep_output_batch(batch) -> List:
        return batch
