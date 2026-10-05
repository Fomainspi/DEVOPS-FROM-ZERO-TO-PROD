# DAY 7 — DEVOPS AUTOMATION PROJECT

> Foundation of Mastering Automation (FOMA)  
> Course: DevOps from Zero to Production  
> Trainer: William Foma

## 1. Project goal

Today integrates the previous skills into one repeatable workflow:

~~~text
Python application
      ↓
Git + GitHub
      ↓
GitHub Actions
      ↓
Docker image
      ↓
Deployment
      ↓
Health check
      ↓
Operational feedback
~~~

The project is intentionally small but follows production-style thinking: automate, validate, observe and document.

## 2. Project structure

~~~text
foma-devops-project/
├── app/
│   ├── app.py
│   └── requirements.txt
├── tests/
│   └── test_app.py
├── scripts/
│   ├── health_check.py
│   └── deploy.sh
├── Dockerfile
├── .dockerignore
├── .gitignore
├── README.md
└── .github/
    └── workflows/
        └── ci.yml
~~~

## 3. Flask application

~~~python
from flask import Flask

app = Flask(__name__)

@app.get("/")
def home():
    return {"message": "Hello from FOMA DevOps Project", "status": "running"}

@app.get("/health")
def health():
    return {"status": "healthy"}

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
~~~

Requirements:

~~~text
Flask
pytest
requests
~~~

Run:

~~~bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r app/requirements.txt
python app/app.py
~~~

Validate:

~~~bash
curl http://localhost:5000/
curl http://localhost:5000/health
~~~

## 4. Automated tests

~~~python
from app.app import app

def test_home():
    client = app.test_client()
    response = client.get("/")
    assert response.status_code == 200

def test_health():
    client = app.test_client()
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json["status"] == "healthy"
~~~

Run:

~~~bash
pytest -q
~~~

A delivery pipeline should reject code that fails its tests.

## 5. Health-check automation

~~~python
import sys
import requests

url = sys.argv[1] if len(sys.argv) > 1 else "http://localhost:5000/health"

response = requests.get(url, timeout=10)
response.raise_for_status()

if response.json().get("status") != "healthy":
    raise SystemExit("Health check failed")

print("Health check passed")
~~~

## 6. Deployment script

~~~bash
#!/usr/bin/env bash
set -euo pipefail

IMAGE="foma-devops-app:local"
CONTAINER="foma-devops-app"

docker build -t "$IMAGE" .
docker rm -f "$CONTAINER" 2>/dev/null || true

docker run -d   --name "$CONTAINER"   -p 5000:5000   "$IMAGE"

echo "Deployment completed"
~~~

The script is intentionally idempotent enough for a lab: it removes an old container before starting a new one.

## 7. Dockerfile

~~~dockerfile
FROM python:3.12-slim

WORKDIR /app

COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app/ app/

EXPOSE 5000

CMD ["python", "app/app.py"]
~~~

For production, improve this with a non-root runtime user, pinned dependencies, image scanning, a production server and health checks.

Docker recommends trusted/minimal base images and multi-stage builds where they reduce the final runtime image. citeturn0search2turn0search7

## 8. CI workflow

Create .github/workflows/ci.yml:

~~~yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"
      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r app/requirements.txt
      - name: Test
        run: pytest -q
      - name: Build image
        run: docker build -t foma-devops-app:ci .
~~~

The delivery gate becomes:

~~~text
Commit / PR
    ↓
Test
    ↓
Docker build
    ↓
PASS → candidate
FAIL → fix
~~~

## 9. Deployment validation

After deployment:

~~~bash
docker ps
docker logs foma-devops-app
curl -f http://localhost:5000/health
~~~

A successful deployment command does not prove the application is healthy. Always validate the running service.

## 10. Cloud deployment concept

The cloud version follows:

~~~text
GitHub → CI → image build → registry → compute → health check → monitoring
~~~

For AWS, the compute target might be EC2, ECS or later Kubernetes/EKS. Do not place private keys, cloud access keys or fixed credentials inside scripts.

## 11. Troubleshooting

### Port already in use

~~~bash
docker ps
ss -tulpn | grep 5000
~~~

Use another host port if necessary.

### Container exits

~~~bash
docker ps -a
docker logs foma-devops-app
~~~

The main container process determines container lifetime.

### Build failure

Check Dockerfile paths, dependency names, Python version and build context.

### CI fails but local tests pass

Compare runtime version, dependencies, environment variables, working directory and filesystem assumptions.

## 12. Hands-on challenge

Build the entire project.

Required:
- [ ] Flask app
- [ ] health endpoint
- [ ] tests
- [ ] Dockerfile
- [ ] .dockerignore
- [ ] deployment script
- [ ] health-check script
- [ ] GitHub repository
- [ ] Actions workflow
- [ ] README architecture
- [ ] troubleshooting guide

Bonus:
- [ ] non-root image
- [ ] vulnerability scanning
- [ ] test coverage
- [ ] structured logging
- [ ] rollback procedure

## 13. Knowledge check

1. Why create a health endpoint?
2. Why test before deployment?
3. What does Docker package?
4. Why use .dockerignore?
5. Why build images in CI?
6. Why validate after deployment?
7. What does curl -f help detect?
8. Why keep secrets outside Git?
9. What is the purpose of deploy.sh?
10. What should you inspect when a container exits?

### Answers

1. It provides a simple operational health signal.
2. To catch defects before promotion.
3. Application and runtime dependencies into an image.
4. To reduce context and avoid unwanted files.
5. To verify the image can be built.
6. A successful command does not guarantee a healthy service.
7. HTTP failures.
8. To prevent credential exposure.
9. To make deployment repeatable.
10. Container status and logs.

## 14. Day 7 outcome

You have now connected coding, version control, CI/CD, containers and operational validation into one project.

**FOMA — Foundation of Mastering Automation**  
Learn • Practice • Build • Advance  
https://foma.life
