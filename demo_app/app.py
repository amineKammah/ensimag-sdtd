import os
import time

from flask import Flask, render_template

from messaging_agent.kafka_agent import KafkaAgent

app = Flask(__name__)

kafka_servers = [os.environ.get("KAFKA_SERVER1"), os.environ.get("KAFKA_SERVER2")]
kafka_agent = KafkaAgent(kafka_servers)

global total_sent, total_processed
total_sent, total_processed = 0, 0


@app.route("/send/<number>")
def send(number: int):
    number = int(number)
    global total_sent
    total_sent += number
    kafka_agent.random_producer("images_feed", number)

    return f"{number} images sent successfully to the service."


@app.route("/get_current_processing")
def get_current_processing_images():
    global total_sent, total_processed
    return f"Currently processing {total_sent - total_processed} images."


@app.route("/get_extracted_text")
def get_extracted_text():
    consumer = kafka_agent.consumer("text_feed", 500, "earliest")
    output = ""
    for event in consumer:
        print(event)
        text = str(event.value)
        if len(text) > 100:
            text = text[:500] + "..."
        output += f'<li class="list-group-item">{text}</li>'

    return output


@app.route("/")
def home():
    return render_template("index.html")
