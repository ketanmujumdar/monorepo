import requests
import os
from flask import Flask, jsonify
import json
import datetime

app = Flask(__name__)

GO_SERVICE_URL = os.getenv('GO_SERVICE_URL', 'http://go-api-service.default.svc.cluster.local:8080')
PHP_SERVICE_URL = os.getenv('PHP_SERVICE_URL', 'http://php-api-service.default.svc.cluster.local:8080')

@app.route('/python_svc', methods=['GET'])
def api():
    python_response = {}
    response = {
        "message": "Hello from the Python API! Calling Go and PHP services",
        "timestamp": datetime.datetime.now().isoformat()
    }

    # Call Go API
    try:
        go_response = requests.get(f"{GO_SERVICE_URL}/go_svc", timeout=5)
        response.raise_for_status()  # Raises an HTTPError for bad responses
        try:
            go_response = response.json()
        except json.JSONDecodeError as e:
            go_response = {"error": f"Failed to parse JSON: {str(e)}", "raw_content": response.text}
        
        python_response["go_api_response"] = go_response
    except requests.RequestException as e:
        python_response["go_api_response"] = f"Error calling Go API: {str(e)}"

    return jsonify(python_response)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=8080)