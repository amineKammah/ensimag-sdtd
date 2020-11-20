import time

from messaging_agent.kafka_agent import KafkaAgent
from run_service import start_service


def tester(kafka_server: str):
    # init
    kafka_agent = KafkaAgent(kafka_server)
    while True:
        num_images = int(input("Enter the number of images to send"))

        consumer = kafka_agent.consumer('text_feed', float('inf'))

        # Send images to OCR service
        kafka_agent.random_producer("images_feed", num_images)

        start = time.time()

        # get results
        extracted_text = []

        for _, text in zip(range(num_images), consumer):
            extracted_text.append(text)

        end = time.time()

        print(f"execution time: {end - start} seconds.\n\n")


from data_processing.ocr_service import OCRService

kafka_servers = ['a04ea17a4263d4e8f9aaecdc8b1b5ed3-1962944993.us-east-1.elb.amazonaws.com:9092',
                 'ab6dd523e279d4d2bb3a60d1ae32fdee-166896499.us-east-1.elb.amazonaws.com:9092']
zk_servers = ['a0efe17d6231542d1a3b0701d747e315-1175272134.us-east-1.elb.amazonaws.com:2181',
              'a112424ef425a4120bdb1866e2e1192d-925634392.us-east-1.elb.amazonaws.com:2181']
k8s_master = 'k8s://https://10.0.0.127:6443'
OCRService(zk_servers, kafka_servers, k8s_master, 'consumer', 'producer').start()
