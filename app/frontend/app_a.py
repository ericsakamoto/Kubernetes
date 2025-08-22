from flask import Flask, request, jsonify
from opentelemetry import trace
from opentelemetry.sdk.resources import SERVICE_NAME, Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.http.trace_exporter import OTLPSpanExporter

from opentelemetry.sdk._logs import LoggerProvider
from opentelemetry.sdk._logs.export import BatchLogRecordProcessor
from opentelemetry.sdk._logs import LoggingHandler  # <-- use this handler
from opentelemetry.exporter.otlp.proto.http._log_exporter import OTLPLogExporter

import logging
import requests
import os

# ---- Traces (unchanged) ----
trace.set_tracer_provider(
    TracerProvider(resource=Resource.create({SERVICE_NAME: "APP-A"}))
)
tracer = trace.get_tracer(__name__)
trace.get_tracer_provider().add_span_processor(
    BatchSpanProcessor(OTLPSpanExporter())
)

# ---- Logs: set up both stdout and OTLP export ----
otel_logger_provider = LoggerProvider(
    resource=Resource.create({SERVICE_NAME: "APP-A"})
)
otel_log_exporter = OTLPLogExporter()
otel_log_processor = BatchLogRecordProcessor(otel_log_exporter)
otel_logger_provider.add_log_record_processor(otel_log_processor)

# Do NOT call opentelemetry.instrumentation.logging.instrument()
# Configure standard logging to stdout
root_logger = logging.getLogger()
root_logger.setLevel(logging.INFO)

# Clear any pre-existing handlers that might suppress stdout in containers
root_logger.handlers = []

stdout_handler = logging.StreamHandler()  # writes to stdout -> visible in `kubectl logs`
stdout_handler.setLevel(logging.INFO)
stdout_handler.setFormatter(logging.Formatter('%(asctime)s %(levelname)s %(message)s'))
root_logger.addHandler(stdout_handler)

# Add OTel logging handler so logs are also exported to your collector
otel_handler = LoggingHandler(level=logging.INFO, logger_provider=otel_logger_provider)
root_logger.addHandler(otel_handler)

logger = logging.getLogger(__name__)
logger.info("Application starting: logs will go to stdout and OTLP")

app = Flask(__name__)
APP_B_URL = os.environ.get("APP_B_URL", "http://app-b:5000/process")

@app.route("/send", methods=["POST"])
def send():
    data = request.get_json()
    value = data.get("value")
    if value is None:
        return jsonify({"error": "Missing 'value'"}), 400
    try:
        logger.info("Calling app_b with value %s", value)
        response = requests.post(APP_B_URL, json={"value": value})
        logger.info("Response from app_b: %s", response.status_code)
        return jsonify(response.json()), response.status_code
    except Exception as e:
        logger.exception("Error calling app_b")  # ensures stack trace in both outputs
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    # In production you would typically run under gunicorn/uwsgi; this is fine for demos.
    app.run(host="0.0.0.0", port=5000)