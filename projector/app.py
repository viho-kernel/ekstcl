from flask import Flask, render_template_string
import socket
import os
from datetime import datetime

app = Flask(__name__)

@app.route('/')
def home():
    hostname = socket.gethostname()
    ip_address = socket.gethostbyname(hostname)
    container_id = os.environ.get('HOSTNAME', 'N/A')
    current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
    html = f"""
    <!DOCTYPE html>
    <html>
    <head>
        <title>Flask App on Minikube</title>
        <style>
            body {{
                font-family: Arial, sans-serif;
                max-width: 800px;
                margin: 50px auto;
                padding: 20px;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
            }}
            .container {{
                background: rgba(0, 0, 0, 0.3);
                padding: 30px;
                border-radius: 10px;
                box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.37);
            }}
            h1 {{
                text-align: center;
                color: #00d4ff;
            }}
            .info {{
                background: rgba(255, 255, 255, 0.1);
                padding: 15px;
                margin: 10px 0;
                border-radius: 5px;
                border-left: 4px solid #00d4ff;
            }}
            .info strong {{
                color: #00d4ff;
            }}
        </style>
    </head>
    <body>
        <div class="container">
            <h1>🐳 Flask App Running in Docker!</h1>
            <div class="info">
                <strong>Container ID:</strong> {container_id}
            </div>
            <div class="info">
                <strong>Hostname:</strong> {hostname}
            </div>
            <div class="info">
                <strong>IP Address:</strong> {ip_address}
            </div>
            <div class="info">
                <strong>Current Time:</strong> {current_time}
            </div>
            <div class="info">
                <strong>Environment:</strong> Docker Container
            </div>
        </div>
    </body>
    </html>
    """
    return render_template_string(html)

@app.route('/health')
def health():
    return {'status': 'healthy'}, 200

@app.route('/api/info')
def api_info():
    return {
        'hostname': socket.gethostname(),
        'ip_address': socket.gethostbyname(socket.gethostname()),
        'container_id': os.environ.get('HOSTNAME', 'N/A'),
        'timestamp': datetime.now().isoformat()
    }

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)