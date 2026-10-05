#!/usr/bin/env bash
set -euo pipefail

LAB="$HOME/foma-day6-python-devops"
mkdir -p "$LAB"
cd "$LAB"

python3 -m venv .venv

cat > system_health.py <<'PY'
#!/usr/bin/env python3
import socket
import subprocess
from datetime import datetime

print("=== FOMA System Health ===")
print("Hostname:", socket.gethostname())
print("Time:", datetime.now().isoformat())

result = subprocess.run(
    ["df", "-h", "/"],
    capture_output=True,
    text=True,
    check=True,
)
print(result.stdout)
PY

chmod +x system_health.py
echo "Lab ready at: $LAB"
echo "Run: source .venv/bin/activate && ./system_health.py"
