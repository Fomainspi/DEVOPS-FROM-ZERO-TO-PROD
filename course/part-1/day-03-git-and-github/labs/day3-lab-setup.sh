#!/usr/bin/env bash
set -euo pipefail
LAB="$HOME/foma-day3-git-lab"
rm -rf "$LAB"
mkdir -p "$LAB/app" "$LAB/docs"
cd "$LAB"
git init -q
git switch -c main >/dev/null 2>&1 || true
printf '%s\n' "# FOMA Git Lab" > README.md
printf '%s\n' "DevOps application" > app/index.html
git add .
git commit -qm "feat: initialize Git lab"
git switch -c feature/documentation >/dev/null
printf '%s\n' "Git provides traceable change history." > docs/git.md
git add docs/git.md
git commit -qm "docs: add Git notes"
git switch main >/dev/null
git merge --no-edit feature/documentation >/dev/null
echo "Git lab ready at $LAB"
git log --oneline --graph --all
