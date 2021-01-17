import os

from flask import Flask, render_template

from messaging_agent.kafka_agent import KafkaAgent

app = Flask(__name__)

kafka_servers = [os.environ.get("KAFKA_SERVER1"), os.environ.get("KAFKA_SERVER2")]
kafka_agent = KafkaAgent(kafka_servers)

global total_sent, total_processed, output
total_sent, total_processed, output = 0, 0, ""


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
    update_extracted_text()
    global output
    return output

def update_extracted_text():
    
    consumer = kafka_agent.consumer("text_feed", 500, "earliest")

    timestamped_text = list(map(consumer, lambda event: (event.timestamp, event.value.decode("utf-8"))))
    sorted_by_time = sorted(timestamped_text, key=lambda element: element[0])
    extracted_text = ""
    for event in sorted_by_image:
        print("event: ", event)
        if len(text) > 500:
            text = text[:500] + "..."
        extracted_text += f'<li kclass="list-group-item">{sorted_by_image[1]}</li>'

    global output, total_processed
    output = extracted_text
    total_processed = len(sorted_by_time)


@app.route("/")
def home():
    return render_template("index.html")
