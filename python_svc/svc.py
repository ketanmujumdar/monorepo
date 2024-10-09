import requests
import os
from flask import Flask, jsonify
import json
import datetime

app = Flask(__name__)

GO_SERVICE_URL = os.getenv('GO_SERVICE_URL', 'http://go-api-service.default.svc.cluster.local:8080')
PHP_SERVICE_URL = os.getenv('PHP_SERVICE_URL', 'http://php-api-service.default.svc.cluster.local:8080')

@app.route('/', methods=['GET'])
def api():
    python_response = {
        "message": "Hello from the Python API! Calling Go and PHP services",
        "timestamp": datetime.datetime.now().isoformat()
    }

    # Call Go API
    try:
        go_response = requests.get(f"{GO_SERVICE_URL}/", timeout=5)
        go_response.raise_for_status()  # Raises an HTTPError for bad responses
        try:
            go_data = go_response.json()
            python_response["go_api_response"] = go_data
        except json.JSONDecodeError as e:
            python_response["go_api_response"] = {
                "error": f"Failed to parse JSON from Go API: {str(e)}",
                "raw_content": go_response.text
            }
    except requests.RequestException as e:
        python_response["go_api_response"] = f"Error calling Go API: {str(e)}"

    return jsonify(python_response)

@app.errorhandler(Exception)
def handle_exception(e):
    # Pass through HTTP errors
    if isinstance(e, requests.HTTPError):
        return jsonify(error=str(e)), e.response.status_code
    # Now handle non-HTTP exceptions
    return jsonify(error=str(e)), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=8080)