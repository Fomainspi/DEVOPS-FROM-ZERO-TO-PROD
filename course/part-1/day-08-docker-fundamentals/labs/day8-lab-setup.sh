#!/usr/bin/env bash
set -euo pipefail

LAB="$HOME/foma-day8-docker-lab"
mkdir -p "$LAB"

cat > "$LAB/app.py" <<'PY'
from http.server import BaseHTTPRequestHandler, HTTPServer

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        body = b"Hello from FOMA Docker Day 8\n"
        self.send_response(200)
        self.send_header("Content-Type", "text/plain")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

HTTPServer(("0.0.0.0", 8000), Handler).serve_forever()
PY

cat > "$LAB/Dockerfile" <<'EOF'
FROM python:3.12-slim
WORKDIR /app
COPY app.py .
EXPOSE 8000
CMD ["python", "app.py"]
EOF

cat > "$LAB/.dockerignore" <<'EOF'
.git
.venv
__pycache__
*.pyc
.env
EOF

echo "Docker lab created at: $LAB"
echo "Build: cd $LAB && docker build -t foma-docker-lab:1.0 ."
echo "Run:   docker run --rm -p 8000:8000 foma-docker-lab:1.0"
