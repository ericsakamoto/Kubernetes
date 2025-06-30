from flask import Flask, request, jsonify
import requests
import os

app = Flask(__name__)

APP_B_URL = os.environ.get("APP_B_URL", "http://app-b:5000/process")

@app.route("/send", methods=["POST"])
def send():
    data = request.get_json()
    value = data.get("value")
    if value is None:
        return jsonify({"error": "Missing 'value'"}), 400

    try:
        response = requests.post(APP_B_URL, json={"value": value})
        return jsonify(response.json()), response.status_code
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
