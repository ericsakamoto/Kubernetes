from flask import Flask, request, jsonify
from opentelemetry import trace
from opentelemetry.sdk.resources import SERVICE_NAME, Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.http.trace_exporter import OTLPSpanExporter
from opentelemetry.sdk._logs import LoggerProvider
from opentelemetry.sdk._logs.export import BatchLogRecordProcessor
from opentelemetry.exporter.otlp.proto.http._log_exporter import OTLPLogExporter

import logging
import requests
import os

# Set up tracing (optional, but common with logging)
trace.set_tracer_provider(
    TracerProvider(
        resource=Resource.create({SERVICE_NAME: "APP-A"})
    )
)
tracer = trace.get_tracer(__name__)
span_processor = BatchSpanProcessor(OTLPSpanExporter())
trace.get_tracer_provider().add_span_processor(span_processor)

# Set up logging
logger_provider = LoggerProvider(
    resource=Resource.create({SERVICE_NAME: "APP-A"})
)
log_exporter = OTLPLogExporter()
log_processor = BatchLogRecordProcessor(log_exporter)
logger_provider.add_log_record_processor(log_processor)

import opentelemetry.instrumentation.logging
opentelemetry.instrumentation.logging.instrument()

# Standard logging usage
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
stream_handler = logging.StreamHandler()
stream_handler.setLevel(logging.INFO)
formatter = logging.Formatter('%(asctime)s %(levelname)s %(message)s')
stream_handler.setFormatter(formatter)
logger.addHandler(stream_handler)
logger.info("This log will be captured by OpenTelemetry")

app = Flask(__name__)

APP_B_URL = os.environ.get("APP_B_URL", "http://app-b:5000/process")

@app.route("/send", methods=["POST"])
def send():
    data = request.get_json()
    value = data.get("value")
    if value is None:
        return jsonify({"error": "Missing 'value'"}), 400

    try:
        logger.info("Calling app_b with value", extra={"value": value})
        response = requests.post(APP_B_URL, json={"value": value})
        logger.info("Response from app_b", extra={"status_code": response.status_code, "response": response.text})
        return jsonify(response.json()), response.status_code
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
