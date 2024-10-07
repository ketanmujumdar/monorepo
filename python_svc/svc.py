from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/python', methods=['GET'])
def api():
    response = {
        "message": "Hello from the Pyton API!"
    }
    return jsonify(response)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=8082)