#!/usr/bin/env bash
set -euo pipefail

LAB_ROOT="$HOME/devops-day1/devops-lab"

echo "Creating Day 1 lab at: $LAB_ROOT"

mkdir -p "$LAB_ROOT"/app
mkdir -p "$LAB_ROOT"/logs
mkdir -p "$LAB_ROOT"/backup
mkdir -p "$LAB_ROOT"/scripts

printf '%s\n' 'APP_NAME=devops-demo' > "$LAB_ROOT/app/app.conf"
printf '%s\n' 'DevOps Application' > "$LAB_ROOT/app/index.html"
printf '%s\n' 'INFO Application started' > "$LAB_ROOT/logs/app.log"
printf '%s\n' 'ERROR Database connection failed' >> "$LAB_ROOT/logs/app.log"
printf '%s\n' 'INFO Application retry started' >> "$LAB_ROOT/logs/app.log"
printf '%s\n' '#!/usr/bin/env bash' > "$LAB_ROOT/scripts/healthcheck.sh"
printf '%s\n' 'echo "DevOps lab health check"' >> "$LAB_ROOT/scripts/healthcheck.sh"

cp "$LAB_ROOT/app/app.conf" "$LAB_ROOT/backup/app.conf"

chmod 755 "$LAB_ROOT/scripts/healthcheck.sh"

echo
echo "Day 1 lab created successfully."
echo
find "$LAB_ROOT" -maxdepth 3 -print
echo
echo "Next practice:"
echo "  cd "$LAB_ROOT""
echo "  grep -n "ERROR" logs/app.log"
echo "  ls -l scripts/healthcheck.sh"
