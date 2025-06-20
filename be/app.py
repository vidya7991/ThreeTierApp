from flask import Flask, request, jsonify
from flask_cors import CORS
import mysql.connector
from mysql.connector import Error

app = Flask(__name__)
CORS(app)
# ✅ Database config (replace with your actual credentials)
DB_CONFIG = {
    'host': 'logindb.cufgya2wi0e8.us-east-1.rds.amazonaws.com',
    'user': 'admin',
    'password': 'YourSecurePassword123!',
    'database': 'loginapp'
}

@app.route('/', methods=['GET'])
def home():
    return "✅ Flask backend is running"

@app.route('/login', methods=['POST'])
def login():
    conn = None
    try:
        data = request.get_json()

        username = data.get('username')
        password = data.get('password')

        if not username or not password:
            return jsonify({'error': 'Username and password are required'}), 400

        # ✅ Connect to MySQL
        conn = mysql.connector.connect(**DB_CONFIG)

        if conn.is_connected():
            cursor = conn.cursor(dictionary=True)
            query = "SELECT * FROM users WHERE username = %s AND password = %s"
            cursor.execute(query, (username, password))
            user = cursor.fetchone()
            cursor.close()

            if user:
                print(f"Login Successful")
                return jsonify({'message': 'Login successful'}), 200
            else:
                return jsonify({'error': 'Invalid username or password'}), 401

        return jsonify({'error': 'Database connection failed'}), 500

    except Error as e:
        print(f"MySQL Error: {e}")
        return jsonify({'error': 'Database error occurred'}), 500

    except Exception as e:
        print(f"General Error: {e}")
        return jsonify({'error': 'Internal server error'}), 500

    finally:
        if conn and conn.is_connected():
            conn.close()

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)