#!/usr/bin/env bash
set -euo pipefail
LAB="$HOME/foma-day4-bash-lab"
mkdir -p "$LAB/scripts" "$LAB/logs" "$LAB/reports"
printf '%s\n' "INFO Application started" > "$LAB/logs/app.log"
printf '%s\n' "INFO Cache connected" >> "$LAB/logs/app.log"
printf '%s\n' "ERROR Database timeout" >> "$LAB/logs/app.log"
cat > "$LAB/scripts/healthcheck.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
echo "Host: $(hostname)"
echo "Date: $(date)"
echo "Disk:"
df -h /
echo "Memory:"
free -h
if command -v systemctl >/dev/null 2>&1 && systemctl is-active --quiet nginx; then
  echo "nginx: ACTIVE"
else
  echo "nginx: INACTIVE or unavailable"
fi
EOF
chmod +x "$LAB/scripts/healthcheck.sh"
echo "Lab ready at $LAB"
echo "Run: $LAB/scripts/healthcheck.sh"
