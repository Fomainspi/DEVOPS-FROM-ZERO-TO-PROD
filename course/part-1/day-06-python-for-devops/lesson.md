# DAY 6 — PYTHON FOR DEVOPS

> Foundation of Mastering Automation (FOMA)  
> Course: DevOps from Zero to Production  
> Trainer: William Foma

## 1. Objectives

Learn enough Python to automate practical DevOps work:

- process files and JSON
- call APIs
- execute Linux commands safely
- use environment variables
- automate AWS tasks
- handle failures
- write useful logs
- build a system-health tool

## 2. Python fundamentals

Check Python:

~~~bash
python3 --version
~~~

Variables and types:

~~~python
name = "FOMA"
age = 42
is_devops = True

print(name)
print(age)
print(is_devops)
~~~

Common types are strings, integers, floats, booleans, lists and dictionaries.

F-strings:

~~~python
name = "William"
print(f"Hello, {name}")
~~~

## 3. Conditions and loops

~~~python
status = "ok"

if status == "ok":
    print("System healthy")
elif status == "warn":
    print("System warning")
else:
    print("System error")
~~~

For loop:

~~~python
for service in ["nginx", "docker", "ssh"]:
    print(service)
~~~

While loop:

~~~python
attempt = 0
while attempt < 3:
    print(f"Attempt {attempt + 1}")
    attempt += 1
~~~

## 4. Functions and collections

~~~python
def greet(name):
    return f"Hello, {name}"

servers = ["web-01", "web-02", "web-03"]

for server in servers:
    print(greet(server))
~~~

Dictionary:

~~~python
server = {
    "name": "web-01",
    "environment": "production",
    "port": 80,
}
print(server["name"])
~~~

Functions turn repeated operations into reusable building blocks.

## 5. Files, paths and JSON

Use pathlib for filesystem work:

~~~python
from pathlib import Path

report = Path("report.txt")
report.write_text("FOMA system report\n")
print(report.read_text())
~~~

JSON:

~~~python
import json
from pathlib import Path

config = {"environment": "dev", "version": 1}

Path("config.json").write_text(json.dumps(config, indent=2))
data = json.loads(Path("config.json").read_text())

print(data["environment"])
~~~

## 6. Environment variables and secrets

Never hard-code production credentials.

~~~python
import os

api_token = os.environ.get("API_TOKEN")

if not api_token:
    raise SystemExit("API_TOKEN is not configured")

print("API token loaded")
~~~

Use environment variables, CI/CD secrets or a dedicated secret manager.

## 7. subprocess and Linux automation

Use subprocess with argument lists:

~~~python
import subprocess

result = subprocess.run(
    ["df", "-h", "/"],
    capture_output=True,
    text=True,
    check=True,
    timeout=10,
)

print(result.stdout)
~~~

Important options:

- capture_output captures stdout/stderr
- text returns strings
- check raises on non-zero exit status
- timeout prevents indefinite hangs

Avoid constructing shell commands directly from untrusted input.

## 8. APIs

Create a virtual environment:

~~~bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install requests
~~~

Call an API:

~~~python
import requests

response = requests.get(
    "https://api.github.com",
    timeout=10,
)
response.raise_for_status()

print(response.json()["current_user_url"])
~~~

Always use timeouts for external network calls.

## 9. AWS automation with Boto3

Install:

~~~bash
python -m pip install boto3
~~~

Example:

~~~python
import boto3

s3 = boto3.client("s3")
response = s3.list_buckets()

for bucket in response["Buckets"]:
    print(bucket["Name"])
~~~

Use IAM roles, configured profiles or environment-based credentials. Never embed cloud access keys in source code.

## 10. Error handling and logging

~~~python
import logging

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(message)s",
)

try:
    value = int("abc")
except ValueError as exc:
    logging.error("Invalid integer: %s", exc)
~~~

Avoid silently swallowing errors:

~~~python
try:
    risky_operation()
except:
    pass
~~~

Silent failure is especially dangerous in automation.

## 11. Virtual environments

~~~bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
pip freeze > requirements.txt
~~~

A reproducible dependency file lets CI and teammates install the same package set.

## 12. Mini-project — system_health.py

Build a script that:

1. prints hostname and time
2. checks disk usage
3. checks memory
4. checks a service
5. calls an HTTP endpoint
6. writes a report
7. exits non-zero when a critical check fails

Starter:

~~~python
#!/usr/bin/env python3

import logging
import socket
import subprocess
from datetime import datetime

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(message)s",
)

def command(args):
    result = subprocess.run(
        args,
        capture_output=True,
        text=True,
        check=True,
        timeout=10,
    )
    return result.stdout.strip()

def main():
    logging.info("Hostname: %s", socket.gethostname())
    logging.info("Time: %s", datetime.now().isoformat())
    logging.info("Disk:\n%s", command(["df", "-h", "/"]))

if __name__ == "__main__":
    main()
~~~

Extend it with memory, service and HTTP checks.

## 13. Troubleshooting

### ModuleNotFoundError

~~~bash
which python
python --version
python -m pip --version
~~~

Make sure the expected virtual environment is active.

### PermissionError

~~~bash
ls -l script.py
~~~

Understand ownership and permissions before reaching for sudo.

### subprocess failure

Capture stderr and the return code:

~~~python
try:
    subprocess.run(
        ["command", "arg"],
        check=True,
        capture_output=True,
        text=True,
    )
except subprocess.CalledProcessError as exc:
    print(exc.returncode)
    print(exc.stderr)
~~~

### API timeout

Use a timeout and implement retries only when retrying is safe.

## 14. Knowledge check

1. Why is Python useful for DevOps?
2. What is a virtual environment?
3. Why use pathlib?
4. Why avoid hard-coded secrets?
5. What does check=True do?
6. Why use network timeouts?
7. What does raise_for_status do?
8. What is Boto3?
9. Why is except-pass dangerous?
10. Why should automation return meaningful exit codes?

### Answers

1. It provides readable automation and strong system/cloud/API libraries.
2. An isolated Python dependency environment.
3. It provides a clear filesystem API.
4. To prevent credential exposure.
5. It raises an exception for a non-zero command exit.
6. To prevent indefinite hangs.
7. It raises for unsuccessful HTTP responses.
8. AWS SDK for Python.
9. It hides failures.
10. CI/CD and operators need a reliable success/failure signal.

## 15. Day 6 checklist

- [ ] Python basics
- [ ] Conditions and loops
- [ ] Functions
- [ ] Files and JSON
- [ ] Environment variables
- [ ] subprocess
- [ ] API call
- [ ] Boto3
- [ ] Logging and error handling
- [ ] System-health project

**FOMA — Foundation of Mastering Automation**  
Learn • Practice • Build • Advance  
https://foma.life
