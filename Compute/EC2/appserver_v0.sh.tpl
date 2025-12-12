#!/bin/bash

#Created by: Abhinav Kumar (abhinav@abhinav-cloud.com)
#Version 1.0

set -e
LOG=/var/log/userdata.log
exec > >(tee -a $LOG) 2>&1

echo "=== Starting Backend User Data ==="

#############################################
# Install packages with retry (Ubuntu)
#############################################
for attempt in {1..10}; do
    apt update && apt install -y python3 python3-pip awscli
    if [ $? -eq 0 ]; then
        echo "APT installation successful"
        break
    fi
    echo "APT failed, retrying... ($attempt)"
    sleep 5
done

pip3 install flask boto3

#############################################
# Wait until S3 is reachable (via VPC endpoint)
#############################################
echo "Checking S3 connectivity..."

BUCKET="${bucket_name}"
REGION="${Region}"

check_s3() {
    aws s3 ls "s3://$BUCKET" --region $REGION >/dev/null 2>&1
}

until check_s3; do
    echo "S3 not reachable yet... waiting..."
    sleep 5
done

echo "S3 is reachable. Proceeding..."

#############################################
# Create application
#############################################
mkdir -p /opt/taskapp

cat << 'PYTHON_EOF' > /opt/taskapp/app.py
from flask import Flask, request, jsonify
import boto3, json
import os

BUCKET = os.environ.get("BUCKET", "${bucket_name}")
FILE_KEY = "tasks.json"

s3 = boto3.client('s3')
app = Flask(__name__)

def get_tasks():
    try:
        obj = s3.get_object(Bucket=BUCKET, Key=FILE_KEY)
        return json.loads(obj['Body'].read().decode())
    except:
        return []

def save_tasks(tasks):
    s3.put_object(
        Bucket=BUCKET,
        Key=FILE_KEY,
        Body=json.dumps(tasks).encode(),
        ContentType='application/json'
    )

@app.route('/api/tasks', methods=['GET'])
def list_tasks():
    return jsonify(get_tasks())

@app.route('/api/tasks', methods=['POST'])
def add_task():
    data = request.json
    tasks = get_tasks()
    tasks.append(data['task'])
    save_tasks(tasks)
    return jsonify({"message": "Task added!"}), 201

@app.route('/health', methods=['GET'])
def health():
    return jsonify({"status": "ok"}), 200

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=8080)
PYTHON_EOF

#############################################
# Create systemd service
#############################################
cat << 'SERVICE_EOF' > /etc/systemd/system/taskapp.service
[Unit]
Description=Task Manager Backend Service
After=network.target

[Service]
ExecStart=/usr/bin/python3 /opt/taskapp/app.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
SERVICE_EOF

systemctl daemon-reload
systemctl enable taskapp
systemctl start taskapp

#############################################
# Verify the service is UP before ALB checks
#############################################
echo "Verifying Flask app is listening on port 8080..."

for i in {1..20}; do
    if curl -s http://localhost:8080/health | grep -q "ok"; then
        echo "App is UP!"
        break
    fi
    echo "Flask app not ready, retrying..."
    sleep 3
done

echo "=== User Data Completed Successfully ==="