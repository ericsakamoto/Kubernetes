FROM python:3.11-slim
WORKDIR /app
COPY . .
RUN pip install flask requests opentelemetry-api opentelemetry-sdk opentelemetry-exporter-otlp opentelemetry-instrumentation-logging
CMD ["python", "app_a.py"]
