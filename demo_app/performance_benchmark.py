import os
import threading
import time

from messaging_agent.kafka_agent import KafkaAgent

kafka_servers = [os.environ.get("KAFKA_SERVER1"), os.environ.get("KAFKA_SERVER2")]
kafka_agent = KafkaAgent(kafka_servers)


def produce_images(n_images):
    print("Producer thread started, sending images to OCR service.")
    for n in range(n_images):
        kafka_agent.random_producer("images_feed", 1, seed=n)
        time.sleep(0.2)


def run_benchmark(n_images):

    consumer = kafka_agent.consumer("text_feed", float("inf"))

    producer_th = threading.Thread(target=produce_images, args=(n_images))
    producer_th.start()

    start = time.time()
    time_list = []
    for processed_n, _ in zip(range(n_images), consumer):
        processing_time = time.time() - start
        time_list.append(processing_time)
        start = time.time()

        print(f"processed image {processed_n + 1}, processing time: {processing_time}.")

    print(time_list)

    producer_th.join()
