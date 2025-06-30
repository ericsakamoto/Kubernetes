from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route("/process", methods=["POST"])
def process():
    data = request.get_json()
    value = data.get("value")
    if value is None:
        return jsonify({"error": "Missing 'value'"}), 400
    result = value * 1000
    return jsonify({"result": result})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)