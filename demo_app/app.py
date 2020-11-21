import os
import time

from flask import Flask, render_template

from messaging_agent.kafka_agent import KafkaAgent

app = Flask(__name__)

kafka_servers = [os.environ.get('KAFKA_SERVER1'), os.environ.get('KAFKA_SERVER2')]
kafka_agent = KafkaAgent(kafka_servers)
consumer = kafka_agent.consumer("text_feed", float("inf"))

global current_processing_images
current_processing_images = 0

global extracted_text
extracted_text = []

@app.route("/send/<number>")
def send(number: int):
    number = int(number)
    global current_processing_images
    current_processing_images += number
    kafka_agent.random_producer("images_feed", number)

    return f"{number} images sent successfully to the service."

@app.route("/get_current_processing")
def get_current_processing_images():
    global current_processing_images
    return f"Currently processing {current_processing_images} images."

@app.route("/get_extracted_text")
def get_extracted_text():
    global extracted_text
    output = ""
    for text in extracted_text:
        if len(text) > 100: text = text[: 500] + "..."
        output += f"<li class=\"list-group-item\">{text}</li>"
    return output

def start_receiver():
    # get results
    global extracted_text
    start = time.time()
    for image_n, text in zip(range(1000), extracted_text):
        extracted_text.append(text)
        current_processing_images -= 1
        print(f"Done extracting image number {image_n}, took: {time.time() - start} seconds.")

@app.route("/")
def home():
    start_receiver()
    return render_template('index.html')

if __name__ == '__main__':
   app.run()