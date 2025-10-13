from flask import Flask, request, jsonify

from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import (
    BatchSpanProcessor,
    ConsoleSpanExporter,
)

from opentelemetry import metrics
from opentelemetry.sdk.metrics import MeterProvider
from opentelemetry.sdk.metrics.export import (
    ConsoleMetricExporter,
    PeriodicExportingMetricReader,
)

from opentelemetry.sdk._logs import LoggerProvider, LoggingHandler
from opentelemetry.sdk._logs.export import BatchLogRecordProcessor, ConsoleLogExporter
from opentelemetry._logs import set_logger_provider, get_logger

import logging
import requests
import os

# ---- Traces ----
print("Setting up tracing...")
provider = TracerProvider()
processor = BatchSpanProcessor(ConsoleSpanExporter())
provider.add_span_processor(processor)

# Sets the global default tracer provider
trace.set_tracer_provider(provider)

# Creates a tracer from the global tracer provider
tracer = trace.get_tracer("skmt.tracer.app_a")

# ---- Metrics ----
print("Setting up metrics...")
metric_reader = PeriodicExportingMetricReader(ConsoleMetricExporter())
provider = MeterProvider(metric_readers=[metric_reader])

# Sets the global default meter provider
metrics.set_meter_provider(provider)

# Creates a meter from the global meter provider
meter = metrics.get_meter("skmt.meter.app_a")

# ---- Logs ----
print("Setting up logging...")
provider = LoggerProvider()
processor = BatchLogRecordProcessor(ConsoleLogExporter())
provider.add_log_record_processor(processor)
# Sets the global default logger provider
set_logger_provider(provider)

logger = get_logger(__name__)

handler = LoggingHandler(level=logging.INFO, logger_provider=provider)
logging.basicConfig(handlers=[handler], level=logging.INFO)

logging.info("This is an OpenTelemetry log record!")


app = Flask(__name__)
APP_B_URL = os.environ.get("APP_B_URL", "http://app-b:5000/process")

@app.route("/send", methods=["POST"])
def send():
    with tracer.start_as_current_span("span-app-a") as span:
        data = request.get_json()
        value = data.get("value")
        if value is None:
            return jsonify({"error": "Missing 'value'"}), 400
        try:
            print("Calling app_b with value", value)
            logging.info("Calling app_b with value %s", value)
            response = requests.post(APP_B_URL, json={"value": value})
            logging.info("Response from app_b: %s", response.status_code)
            return jsonify(response.json()), response.status_code
        except Exception as e:
            logging.exception("Error calling app_b")  # ensures stack trace in both outputs
            return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    # In production you would typically run under gunicorn/uwsgi; this is fine for demos.
    app.run(host="0.0.0.0", port=5000)