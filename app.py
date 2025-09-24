from flask import Flask, request, jsonify
from flask_cors import CORS
import os
import requests
from config import config

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "https://inax-ai.vercel.app"}})

# Load configuration
config_name = os.getenv('FLASK_ENV', 'default')
app.config.from_object(config[config_name])
config[config_name].init_app(app)

GROQ_API_KEY = app.config['GROQ_API_KEY']
API_URL = app.config['API_URL']

HEADERS = {
    "Authorization": f"Bearer {GROQ_API_KEY}",
    "Content-Type": "application/json"
}

@app.route('/', methods=['GET'])
def home():
    return "✅ Flask server is running! Use POST /chat to talk to the bot."

@app.route('/chat', methods=['POST'])
def chat():
    try:
        data = request.get_json()
        if not data or 'message' not in data:
            return jsonify({'error': 'No message provided'}), 400
        
        user_message = data.get('message', '')
        if not user_message.strip():
            return jsonify({'error': 'Empty message'}), 400
        
        reply = chat_with_llama(user_message)
        print(f"User message: {user_message}")
        print(f"Bot reply: {reply}")
        return jsonify({'reply': reply})
    except Exception as e:
        print(f"Error in chat endpoint: {e}")
        return jsonify({'error': 'Internal server error'}), 500

def chat_with_llama(prompt):
    if not GROQ_API_KEY:
        return "Error: GROQ_API_KEY not found in environment variables"
    
    payload = {
        "model": "openai/gpt-oss-120b",
        "messages": [
            {"role": "system", "content": "You are a helpful and concise assistant. Provide detailed and point-wise answers."},
            {"role": "user", "content": prompt}
        ],
        "max_tokens": 1024,
        "temperature": 0.5,
        "top_p": 0.95,
        "stream": False
    }
    
    try:
        response = requests.post(API_URL, headers=HEADERS, json=payload, timeout=30)
        print(f"API Status code: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            reply = data['choices'][0]['message']['content']
            return reply
        else:
            print(f"API Error: {response.status_code} - {response.text}")
            return f"Error from Groq API: {response.status_code} - {response.text}"
    except requests.exceptions.RequestException as e:
        print(f"Request error: {e}")
        return f"Network error: {str(e)}"
    except Exception as e:
        print(f"Unexpected error: {e}")
        return f"Unexpected error: {str(e)}"

if __name__ == "__main__":
    print("Starting Flask server...")
    print(f"API Key present: {'Yes' if GROQ_API_KEY else 'No'}")
    print("Chat endpoint available at: http://localhost:5000/chat")
    
    # Get port from environment variable or default to 5000
    port = int(os.environ.get('PORT', 5000))
    debug = os.environ.get('FLASK_ENV') == 'development'
    
    app.run(host='0.0.0.0', port=port, debug=debug)

    
