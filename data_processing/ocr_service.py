from typing import List
import os

from pyspark import SparkContext, SparkConf
from pyspark.streaming import StreamingContext
from pyspark.streaming.kafka import KafkaUtils

from messaging_agent.kafka_agent import KafkaAgent

from data_processing.optical_character_recognizer import OpticalCharacterRecognizer


class OCRService:
    def __init__(self, zk_quorums: List[str], kafka_servers: List[str], k8s_master: str, consumer_topic: str, producer_topic: str):
#         os.environ['PYSPARK_SUBMIT_ARGS'] = (
#             '--jars /opt/spark/spark-streaming-kafka-0-8-assembly_2.11-2.4.4.jar,' +
#             '/opt/spark/spark-kubernetes_2.12-2.4.4.jar pyspark-shell'
#         )

        os.environ['PYSPARK_SUBMIT_ARGS'] = (
            '--jars /opt/spark/spark-streaming-kafka-0-8-assembly_2.11-2.4.4.jar pyspark-shell'
        )

        self.zk_quorums = zk_quorums
        self.kafka_servers = kafka_servers
        self.consumer_topic = consumer_topic
        self.producer_topic = producer_topic
        self.k8s_master = k8s_master

    @staticmethod
    def _process_event(event, kafka_servers, topic):
        print(f"Processing image: {event[1]}")
        extracted_text = OpticalCharacterRecognizer.extract(event[1])

        KafkaAgent(kafka_servers).produce(topic, [extracted_text])

        return extracted_text

    def start(self) -> None:
        sparkConf = SparkConf()
#         sparkConf.setMaster(self.k8s_master)
        sparkConf.setAppName("OCRService")
#         sparkConf.set("spark.kubernetes.container.image", "kammahm/sdtd_data_processing:latest")
#         sparkConf.set("spark.executor.instances", 1)
#         sparkConf.set("spark.executor.cores", 2)

        sc = SparkContext(conf=sparkConf)
        sc.addPyFile('/ensimag-sdtd/data_processing/optical_character_recognizer.py')
        from data_processing.optical_character_recognizer import OpticalCharacterRecognizer

        ssc = StreamingContext(sc, 2)
        kvs = KafkaUtils.createStream(ssc, self.zk_quorums[0], "event-consumer", {self.consumer_topic:1})

        kvs.map(lambda event: OCRService._process_event(event, self.kafka_servers, self.producer_topic)).pprint()

        ssc.start()
        ssc.awaitTermination()
