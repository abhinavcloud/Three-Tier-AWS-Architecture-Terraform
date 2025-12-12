#!/bin/bash

#Created by: Abhinav Kumar (abhinav@abhinav-cloud.com)
#Version 1.0

set -euo pipefail

LOG=/var/log/backend-userdata.log
exec > >(tee -a "$LOG") 2>&1

echo "=== Backend Boot Start ==="

APP_DIR="/opt/taskapp"
VENV="$APP_DIR/venv"

export BUCKET="${bucket_name}"
export AWS_DEFAULT_REGION="${region}"

echo "BUCKET=$BUCKET" >> /etc/environment
echo "AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION" >> /etc/environment
source /etc/environment

for i in {1..6}; do
  if apt-get update -y && apt-get install -y python3 python3-pip python3-venv awscli curl; then
    break
  fi
  sleep 5
done

mkdir -p "$APP_DIR"
python3 -m venv "$VENV"
source "$VENV/bin/activate"
pip install flask boto3 --quiet

# Ensure S3 available
until aws s3 ls "s3://$BUCKET" >/dev/null 2>&1; do
  echo "Waiting for S3..."
  sleep 5
done

# Flask App
cat > "$APP_DIR/app.py" << 'EOF'
from flask import Flask, request, jsonify
import boto3, json, os

BUCKET = os.environ["BUCKET"]
KEY = "tasks.json"
s3 = boto3.client('s3')
app = Flask(__name__)

def load_tasks():
    try:
        obj = s3.get_object(Bucket=BUCKET, Key=KEY)
        return json.loads(obj['Body'].read().decode())
    except:
        return []

def save_tasks(t):
    s3.put_object(Bucket=BUCKET, Key=KEY, Body=json.dumps(t))

@app.route("/api/tasks", methods=["GET"])
def get_tasks():
    return jsonify(load_tasks())

@app.route("/api/tasks", methods=["POST"])
def add_task():
    data = request.json
    tasks = load_tasks()
    tasks.append(data["task"])
    save_tasks(tasks)
    return {"status":"added"},201

@app.route("/health")
def health():
    return {"ok":True},200

if __name__=="__main__":
    app.run(host="0.0.0.0", port=8080)
EOF

# systemd service
cat > /etc/systemd/system/taskapp.service <<EOF
[Unit]
Description=Flask Backend
After=network.target

[Service]
Type=simple
WorkingDirectory=$APP_DIR
Environment=BUCKET=$BUCKET
ExecStart=$VENV/bin/python $APP_DIR/app.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable taskapp --now

echo "=== Backend ready ==="
