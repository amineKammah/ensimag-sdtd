from messaging_agent.kafka_agent import KafkaAgent
from data_processing.ocr_service import OCRService


def tester(kafka_server: str, num_images: int = 100):
    # init
    kafka_agent = KafkaAgent(kafka_server)
    kafka_agent.create_topic("ocr_images")
    kafka_agent.create_topic("extracted_text")
    OCRService(kafka_server, "ocr_images", "extracted_text", distribution_threshold=1_000).start()

    # Send images to OCR service
    kafka_agent.random_producer("ocr_images", num_images)

    # get results
    consumer = kafka_agent.consumer("extracted_text", float('inf'))
    extracted_text = []
    for _, text in zip(range(100), consumer):
        extracted_text.append(text)

    print(extracted_text)





