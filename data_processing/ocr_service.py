import os
from typing import *

from pyspark import SparkConf, SparkContext
from pyspark.streaming import StreamingContext
from pyspark.streaming.kafka import KafkaUtils

from data_processing.optical_character_recognizer import \
    OpticalCharacterRecognizer
from messaging_agent.kafka_agent import KafkaAgent


class OCRService:
    def __init__(
        self,
        zk_quorums: List[str],
        kafka_servers: List[str],
        k8s_master: str,
        consumer_topic: str,
        producer_topic: str,
    ):

        os.environ[
            "PYSPARK_SUBMIT_ARGS"
        ] = "--jars /opt/spark/sp/opt/spark/spark-streaming-kafka-0-8-assembly_2.11-2.4.4.jarark-streaming-kafka-0-8-assembly_2.11-2.4.4.jar pyspark-shell"

        self.zk_quorums = zk_quorums
        self.kafka_servers = kafka_servers
        self.consumer_topic = consumer_topic
        self.producer_topic = producer_topic
        self.k8s_master = k8s_master

    @staticmethod
    def _process_event(event, kafka_servers, topic):
        try:
            image_path = event[1]
            extracted_text = OpticalCharacterRecognizer.extract(image_path)

            value = json.dumps({"image": image_path, "text": extracted_text}).encode("ascii")
            KafkaAgent(kafka_servers).produce(topic, value=value)
        except Exception as e:
            error_msg = f"Error in extracting text: {e}"
            KafkaAgent(kafka_servers).produce(topic, value=bytes(error_msg, "ascii")
            return error_msg

        return extracted_text

    def start(self) -> None:
        sparkConf = SparkConf()
        sparkConf.setAppName("OCRService")

        sc = SparkContext(conf=sparkConf)
        sc.addPyFile("/ensimag-sdtd/data_processing/optical_character_recognizer.py")
        from data_processing.optical_character_recognizer import \
            OpticalCharacterRecognizer

        ssc = StreamingContext(sc, 2)
        kvs = KafkaUtils.createStream(
            ssc, self.zk_quorums[0], "event-consumer", {self.consumer_topic: 10}
        )

        kvs.map(
            lambda event: OCRService._process_event(
                event, self.kafka_servers, self.producer_topic
            )
        ).pprint()

        ssc.start()
        ssc.awaitTermination()
