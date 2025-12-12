#!/bin/bash

#Created by: Abhinav Kumar (abhinav@abhinav-cloud.com)
#Version 1.0

set -euo pipefail

LOG=/var/log/userdata.log
exec > >(tee -a "$LOG") 2>&1

echo "=== Frontend user-data start ==="

# ------------------------
# Inject Terraform var once
# ------------------------
export BACKEND_DNS="${internal_alb_dns_name}"   # rendered by Terraform once
# persist across reboots (optional)
echo "BACKEND_DNS=$BACKEND_DNS" >> /etc/environment
source /etc/environment

WEBROOT="/var/www/html"

# ------------------------
# Wait for basic network
# ------------------------
echo "Waiting for network..."
until ping -c1 8.8.8.8 &>/dev/null; do
  echo "Network not ready; retrying..."
  sleep 3
done
echo "Network looks good"

# ------------------------
# Install packages (retries)
# ------------------------
for i in {1..8}; do
  if apt-get update -y && apt-get install -y nginx curl; then
    echo "Packages installed"
    break
  fi
  echo "APT failed, attempt $i/8; retrying..."
  sleep 5
done

# Ensure webroot exists
mkdir -p "$WEBROOT"

# ------------------------
# Create static files locally (index + health)
# Use placeholder BACKEND_DNS_PLACEHOLDER inside HTML then replace
# ------------------------
cat > "$WEBROOT/health" <<'HEALTH_EOF'
OK
HEALTH_EOF
chmod 644 "$WEBROOT/health"

cat > "$WEBROOT/index.html" <<'HTML_EOF'
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8"/>
<title>Task Manager</title>

<style>
  body {
    font-family: Arial, sans-serif;
    background:#0a0a0c; /* Dark mode */
    margin:0;
    padding:40px;         /* Move content into view */
    color:white;
  }

  .container {
    max-width:450px;
    margin:auto;
    background:#1a1d24;   /* Contrasting panel */
    padding:30px;
    border-radius:12px;
    border:1px solid #333;
    box-shadow:0 0 20px rgba(0,0,0,0.7);
  }

  h2 { text-align:center; margin-bottom:20px; }

  input {
    width:100%;
    padding:12px;
    background:#262a33;
    color:white;
    border:1px solid #444;
    border-radius:6px;
    margin-bottom:12px;
    font-size:15px;
  }

  button {
    width:100%;
    padding:12px;
    background:#00aaff;        /* Very visible */
    color:black;
    font-size:16px;
    font-weight:bold;
    border:none;
    border-radius:6px;
    cursor:pointer;
    margin-bottom:25px;
    transition:.3s;
  }
  button:hover { background:#22c4ff; }

  h3 { margin-bottom:10px; }

  ul { list-style:none; padding:0; }

  li {
    background:#2d323d;
    padding:12px;
    margin-bottom:10px;
    border-radius:6px;
    font-size:15px;
    border-left:4px solid #00aaff;
  }
</style>
</head>

<body>

<div class="container">
  <h2>📝 Task Manager</h2>
  <h3> Use this application to Add and List Tasks To Do</h3>

  <input id="taskInput" placeholder="Enter a task ..." />
  <button onclick="addTask()">Add Task</button>

  <h3>Task List:</h3>

  <ul id="taskList"></ul>
</div>

<script>
const backend="/api/tasks";

async function loadTasks(){
  try{
    const res = await fetch(backend);
    const data = await res.json();
    document.getElementById("taskList").innerHTML =
      data.map(t=>`<li>$${t}</li>`).join('');
  }catch{
    console.log("Backend not reachable — using sample items");
  }
}

async function addTask(){
  const task=document.getElementById("taskInput").value.trim();
  if(!task) return;

  try{
    await fetch(backend,{
      method:"POST",
      headers:{ "Content-Type":"application/json" },
      body:JSON.stringify({task})
    });
    document.getElementById("taskInput").value="";
    loadTasks();
  }catch(e){ console.log(e); }
}

loadTasks();
</script>

</body>
</html>
HTML_EOF

# >>> ADD HERE <<<
# Create empty favicon to avoid browser auto-request 404
echo "" > "$WEBROOT/favicon.ico"
chmod 644 "$WEBROOT/favicon.ico"
# <<< END ADDITION >>>

# Replace placeholder with actual BACKEND_DNS safely
# Use sed; escape slashes in BACKEND_DNS if necessary
ESC_BACKEND=$(printf '%s\n' "$BACKEND_DNS" | sed -e 's/[\/&]/\\&/g')
sed -i "s/BACKEND_DNS_PLACEHOLDER/$ESC_BACKEND/g" "$WEBROOT/index.html"

# ------------------------
# Nginx site config (expand BACKEND_DNS; but keep literal $host/$remote_addr)
# ------------------------
cat > /etc/nginx/sites-available/default <<EOF
server {
    listen 80;

    location / {
        root $WEBROOT;
        index index.html;
    }

    location /api/ {
        proxy_pass http://$BACKEND_DNS:8080/api/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
    }

    location /health {
        root $WEBROOT;
        try_files /health =404;
    }
}
EOF

# Test nginx config and reload
nginx -t && systemctl enable nginx
systemctl restart nginx

# ------------------------
# Verify service readiness
# ------------------------
echo "Verifying frontend on localhost..."
for i in {1..12}; do
  if curl -sSf http://localhost/health &>/dev/null; then
    echo "Frontend ready"
    break
  fi
  echo "Frontend not ready yet ($i/12)..."
  sleep 3
done

echo "=== Frontend user-data completed ==="
