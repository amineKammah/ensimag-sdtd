import os
import time

from messaging_agent.kafka_agent import KafkaAgent

kafka_servers = [os.environ.get("KAFKA_SERVER1"), os.environ.get("KAFKA_SERVER2")]
kafka_agent = KafkaAgent(kafka_servers)


def run_benchmark(n_images):

    consumer = kafka_agent.consumer("text_feed", float("inf"))

    kafka_agent.random_producer("images_feed", n_images)

    time_list = []
    start = time.time()

    for processed_n, _ in zip(range(n_images), consumer):
        processing_time = time.time() - start
        time_list.append(processing_time)
        start = time.time()

        print(f"processed image {processed_n + 1}, processing time: {processing_time}.")

    print(time_list)
