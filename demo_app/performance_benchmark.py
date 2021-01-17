import os
import threading
import time
import random

from messaging_agent.kafka_agent import KafkaAgent

kafka_servers = [os.environ.get("KAFKA_SERVER1"), os.environ.get("KAFKA_SERVER2")]
kafka_agent = KafkaAgent(kafka_servers)

SPARK_EXECUTERS = 2

global total_received, time_list
total_received = 0
time_list = []


def receive_images(n_images):

    print("Receiver thread started, Receiving images from OCR service.")
    receiver = kafka_agent.consumer("text_feed", float("inf"))
    global total_received, time_list

    start = time.time()
    for _ in receiver:
        processing_time = time.time() - start
        time_list.append(processing_time)
        start = time.time()

        print(f"processed image {total_received + 1}, processing time: {processing_time}.")

        total_received += 1


def run_benchmark(n_images):
    receiver_th = threading.Thread(target=receive_images, args=(n_images,))
    receiver_th.start()

    global total_received, time_list
    total_sent = 0
    while total_received < n_images:
        if total_sent - total_received < 2 * SPARK_EXECUTERS:
            kafka_agent.random_producer("images_feed", 1, seed=42)
            total_sent += 1
            print(f"send {total_sent} images.")

        time.sleep(random.random())

    print(time_list)
    print("The average response time:", sum(time_list) / n_images)

    receiver_th.join()
