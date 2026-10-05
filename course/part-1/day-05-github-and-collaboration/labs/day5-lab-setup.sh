#!/usr/bin/env bash
set -euo pipefail

LAB="$HOME/foma-day5-github-lab"
mkdir -p "$LAB"
cd "$LAB"

git init
git branch -M main

cat > README.md <<'EOF'
# FOMA GitHub Collaboration Lab
Practice repository for Day 5.
EOF

cat > .gitignore <<'EOF'
.env
*.pem
*.key
__pycache__/
EOF

git add README.md .gitignore
git commit -m "chore: initialize collaboration lab"

git switch -c feature/health-check
printf '\n## Health Check\n\nExpected endpoint: GET /health\n' >> README.md
git add README.md
git commit -m "docs: add health check documentation"

echo "Lab ready at: $LAB"
echo "Connect it to your GitHub repository and push the main and feature branches."
