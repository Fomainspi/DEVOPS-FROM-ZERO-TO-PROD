#!/usr/bin/env bash
set -euo pipefail

LAB="$HOME/foma-day7-project"
mkdir -p "$LAB"/{app,tests,scripts,.github/workflows}

cat > "$LAB/app/app.py" <<'PY'
from flask import Flask

app = Flask(__name__)

@app.get("/")
def home():
    return {"message": "Hello from FOMA DevOps Project", "status": "running"}

@app.get("/health")
def health():
    return {"status": "healthy"}
PY

cat > "$LAB/app/requirements.txt" <<'EOF'
Flask
pytest
requests
EOF

cat > "$LAB/tests/test_app.py" <<'PY'
from app.app import app

def test_health():
    client = app.test_client()
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json["status"] == "healthy"
PY

echo "Project scaffold created at: $LAB"
