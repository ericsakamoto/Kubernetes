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

# Set up tracing (optional, but common with logging)
trace.set_tracer_provider(
    TracerProvider(
        resource=Resource.create({SERVICE_NAME: "APP-B"})
    )
)
tracer = trace.get_tracer(__name__)
span_processor = BatchSpanProcessor(OTLPSpanExporter())
trace.get_tracer_provider().add_span_processor(span_processor)

# Set up logging
logger_provider = LoggerProvider(
    resource=Resource.create({SERVICE_NAME: "APP-B"})
)
log_exporter = OTLPLogExporter()
log_processor = BatchLogRecordProcessor(log_exporter)
logger_provider.add_log_record_processor(log_processor)

import opentelemetry.instrumentation.logging
opentelemetry.instrumentation.logging.instrument()

# Standard logging usage
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
logger.info("This log will be captured by OpenTelemetry")

app = Flask(__name__)

@app.route("/process", methods=["POST"])
def process():
    data = request.get_json()
    value = data.get("value")
    logger.info("Input value received", extra={"value": value})
    if value is None:
        return jsonify({"error": "Missing 'value'"}), 400
    result = value * 1000
    logger.info("Processed value", extra={"result": result})
    return jsonify({"result": result})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)