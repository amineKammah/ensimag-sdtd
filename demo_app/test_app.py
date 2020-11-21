import os
import time

from messaging_agent.kafka_agent import KafkaAgent


def tester():
    # init
    kafka_servers = [os.environ.get("KAFKA_SERVER1"), os.environ.get("KAFKA_SERVER2")]
    kafka_agent = KafkaAgent(kafka_servers)
    while True:
        num_images = int(input("Enter the number of images to send: "))

        consumer = kafka_agent.consumer("text_feed", float("inf"))

        # Send images to OCR service
        kafka_agent.random_producer("images_feed", num_images)

        start = time.time()

        # get results
        extracted_text = []

        for image_n, text in zip(range(num_images), consumer):
            extracted_text.append(text)
            print(
                f"Done extracting image number {image_n}, took: {time.time() - start} seconds."
            )

        end = time.time()

        print(f"execution time: {end - start} seconds.\n\n")


if __name__ == "__main__":
    tester()
