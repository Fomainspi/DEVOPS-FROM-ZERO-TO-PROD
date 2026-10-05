#!/usr/bin/env bash
set -euo pipefail
LAB="$HOME/foma-day2-admin-lab"
mkdir -p "$LAB"
printf '%s\n' "FOMA Linux Administration Lab" > "$LAB/README.txt"
printf '%s\n' "INFO nginx check started" > "$LAB/app.log"
printf '%s\n' "ERROR sample database timeout" >> "$LAB/app.log"
printf '%s\n' "INFO investigation completed" >> "$LAB/app.log"
echo "Created $LAB"
echo "Try: grep -n ERROR $LAB/app.log"
echo "Then practice: df -h, free -h, ps aux, ss -tulpn"
