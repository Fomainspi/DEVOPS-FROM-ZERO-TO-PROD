# DEVOPS FROM ZERO TO PRODUCTION
## PART 1 — DEVOPS & LINUX FOUNDATION
# DAY 4 — BASH SCRIPTING & AUTOMATION

**Foundation of Mastering Automation (FOMA)**  
**William Foma — DevOps Trainer**  
**https://foma.life**

---

## 1. Day 4 Mission

A DevOps engineer should not repeatedly perform the same manual operation when a safe, tested script can perform it consistently.

Today you begin turning Linux commands into **automation**.

By the end of Day 4 you should be able to:

- explain what Bash is;
- create and execute shell scripts;
- understand shebangs;
- use variables;
- accept arguments;
- use exit codes;
- chain commands safely;
- use conditions;
- use loops;
- create functions;
- validate input;
- redirect output;
- handle basic errors;
- automate a health check;
- write a practical DevOps backup/monitoring script.

---

## 2. What Is Bash?

Bash means **Bourne Again SHell**.

A shell provides a command interpreter. Bash can also execute scripts containing commands, variables, conditions, loops and functions.

Instead of:

```bash
mkdir logs
date
df -h
free -h
ps aux
```

manually every day, you can create:

```bash
./system-health.sh
```

and automate the sequence.

> 💡 **DEVOPS TIP:** Automation should reduce human repetition without hiding important operational decisions.

---

## 3. Your First Script

Create:

```bash
$ mkdir bash-lab
$ cd bash-lab
$ nano hello.sh
```

Content:

```bash
#!/usr/bin/env bash

echo "Hello from FOMA DevOps training"
```

The first line is the **shebang**. It tells the operating system which interpreter should execute the script.

Make executable:

```bash
$ chmod +x hello.sh
```

Run:

```bash
$ ./hello.sh
```

Expected:

```
Hello from FOMA DevOps training
```

You can also run:

```bash
$ bash hello.sh
```

---

## 4. Variables

Assign:

```bash
NAME="William"
ROLE="DevOps Engineer"
```

Use:

```bash
echo "$NAME"
echo "$ROLE"
```

Important:

```bash
NAME="William"
```

Correct.

```bash
NAME = "William"
```

Incorrect because spaces around assignment have meaning in Bash.

### Quote variables

Prefer:

```bash
echo "$NAME"
```

Quoting helps preserve spaces and prevents unintended word splitting.

---

## 5. Command Substitution

Store command output:

```bash
HOSTNAME=$(hostname)
DATE=$(date)
```

Then:

```bash
echo "Host: $HOSTNAME"
echo "Time: $DATE"
```

This is useful when scripts need system information.

---

## 6. Script Arguments

Create:

```bash
#!/usr/bin/env bash

echo "Script name: $0"
echo "First argument: $1"
echo "Second argument: $2"
echo "Number of arguments: $#"
```

Run:

```bash
./args.sh production nginx
```

Output:

```
Script name: ./args.sh
First argument: production
Second argument: nginx
Number of arguments: 2
```

Useful variables:

| Variable | Meaning |
|---|---|
| `$0` | Script name |
| `$1` | First argument |
| `$2` | Second argument |
| `$#` | Number of arguments |
| `$@` | All arguments |
| `$?` | Previous command exit status |

---

## 7. Exit Codes

Linux commands communicate success/failure through exit status.

Success:

```bash
$ true
$ echo $?
0
```

Failure:

```bash
$ false
$ echo $?
1
```

Convention:

```
0     success
non-0 failure
```

DevOps automation relies heavily on exit codes because CI/CD systems need to know whether a command succeeded.

---

## 8. Safe Script Defaults

For operational scripts, a useful starting point is:

```bash
#!/usr/bin/env bash
set -euo pipefail
```

Meaning:

- `-e`: exit when a command fails;
- `-u`: treat unset variables as errors;
- `pipefail`: a pipeline fails if an important command in it fails.

This is not magic and does not replace validation/testing. It is a safer baseline for many scripts.

---

## 9. Conditions

Basic:

```bash
if [[ -f "app.conf" ]]; then
    echo "Configuration exists"
else
    echo "Configuration is missing"
fi
```

Directory:

```bash
if [[ -d "/var/log" ]]; then
    echo "Log directory exists"
fi
```

String:

```bash
if [[ "$ENV" == "production" ]]; then
    echo "Production environment"
fi
```

Numeric comparison:

```bash
if (( COUNT > 10 )); then
    echo "Threshold exceeded"
fi
```

---

## 10. Loops

For loop:

```bash
for server in web01 web02 web03; do
    echo "Checking $server"
done
```

Iterate over files:

```bash
for file in *.log; do
    echo "Processing $file"
done
```

While loop:

```bash
COUNT=1

while (( COUNT <= 3 )); do
    echo "Attempt $COUNT"
    ((COUNT++))
done
```

> 🚀 **REAL-WORLD SCENARIO:** Loops are useful when the same health check, deployment step or file operation must be performed across multiple targets.

---

## 11. Functions

Functions organize reusable logic.

```bash
log_info() {
    echo "[INFO] $1"
}

log_error() {
    echo "[ERROR] $1"
}

log_info "Application started"
log_error "Database unavailable"
```

A production script should avoid repeating large blocks of commands.

---

## 12. Input Validation

Never assume required input exists.

```bash
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <environment>"
    exit 1
fi

ENVIRONMENT="$1"
```

Now:

```bash
./deploy-check.sh
```

returns a useful message instead of behaving unpredictably.

---

## 13. Redirection and Pipes

Overwrite:

```bash
echo "Line 1" > app.log
```

Append:

```bash
echo "Line 2" >> app.log
```

Standard error:

```bash
command 2> errors.log
```

Both output streams:

```bash
command > output.log 2>&1
```

Pipe:

```bash
ps aux | grep '[n]ginx'
```

Pipes allow one command's output to become another command's input.

---

## 14. Environment Variables

View:

```bash
echo "$HOME"
echo "$PATH"
```

Set for the current shell:

```bash
export APP_ENV="development"
```

Verify:

```bash
echo "$APP_ENV"
```

Environment variables are commonly used to pass configuration to applications and automation.

Do not put secrets directly into scripts.

> ⚠️ **SECURITY WARNING:** Avoid hardcoding passwords, API tokens and private keys.

---

## 15. Practical DevOps Script — Health Check

Create `healthcheck.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "=== FOMA SYSTEM HEALTH CHECK ==="
echo "Host: $(hostname)"
echo "Date: $(date)"
echo

echo "--- Uptime ---"
uptime
echo

echo "--- Memory ---"
free -h
echo

echo "--- Disk ---"
df -h /
echo

echo "--- Nginx ---"
if systemctl is-active --quiet nginx; then
    echo "nginx: ACTIVE"
else
    echo "nginx: INACTIVE"
    exit 1
fi

echo
echo "Health check completed successfully."
```

Make executable:

```bash
chmod +x healthcheck.sh
```

Run:

```bash
./healthcheck.sh
```

This is already a small operational automation tool.

---

## 16. Practical DevOps Script — Log Analyzer

Create:

```bash
#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="${1:-app.log}"

if [[ ! -f "$LOG_FILE" ]]; then
    echo "ERROR: log file not found: $LOG_FILE" >&2
    exit 1
fi

echo "Analyzing: $LOG_FILE"
echo "ERROR count: $(grep -ic "error" "$LOG_FILE" || true)"
echo
echo "Recent errors:"
grep -in "error" "$LOG_FILE" | tail -n 10 || true
```

Run:

```bash
./log-analyzer.sh logs/app.log
```

Notice that `grep` may return a non-zero status when no match exists. The script intentionally handles that case.

---

## 17. Bash Script Debugging

Run a script with tracing:

```bash
bash -x script.sh
```

Check syntax without executing:

```bash
bash -n script.sh
```

Inspect permissions:

```bash
ls -l script.sh
```

Common problems:

- missing shebang;
- missing execute permission;
- incorrect quoting;
- unbound variables;
- wrong relative path;
- command unavailable;
- unexpected exit code.

---

## 18. Hands-On Lab — Automated Server Health

Create:

```
foma-bash-lab/
├── scripts/
│   ├── healthcheck.sh
│   └── log-analyzer.sh
├── logs/
│   └── app.log
└── reports/
```

Create log data:

```bash
echo "INFO Application started" > logs/app.log
echo "INFO Connected to cache" >> logs/app.log
echo "ERROR Database timeout" >> logs/app.log
echo "INFO Retry started" >> logs/app.log
```

Your script must:

1. print hostname;
2. print current date;
3. show disk usage;
4. show memory;
5. verify nginx;
6. count ERROR entries;
7. return a non-zero status if nginx is inactive.

Run:

```bash
bash -n scripts/healthcheck.sh
bash -x scripts/healthcheck.sh
```

---

## 19. Troubleshooting Scenario

### Problem

The CI pipeline reports:

```
Process completed with exit code 1
```

Investigate:

```bash
bash -n script.sh
bash -x script.sh
echo $?
```

Questions:

1. Did the script fail because of syntax?
2. Which command failed?
3. What was the exit status?
4. Did an unset variable cause the failure?
5. Did a file path contain spaces?
6. Did a command return non-zero because there was no matching result?

> 🧠 **REMEMBER:** "exit code 1" is not a diagnosis. It is evidence that the script reported failure. Find the command that caused it.

---

## 20. Day 4 Practice Challenge

Build `devops-report.sh`.

Requirements:

- accept an output filename as argument;
- validate the argument;
- write hostname;
- write date;
- write uptime;
- write memory usage;
- write root filesystem usage;
- list top five CPU-consuming processes;
- report whether nginx is active;
- write the report to the requested file;
- return non-zero if nginx is inactive.

Example:

```bash
./devops-report.sh reports/server-report.txt
```

Then verify:

```bash
cat reports/server-report.txt
echo $?
```

---

## 21. Knowledge Check

1. What is Bash?
2. What is a shebang?
3. What does chmod +x do?
4. What is a variable?
5. What does `$1` mean?
6. What does `$#` mean?
7. What does `$?` represent?
8. What does exit code 0 normally mean?
9. Why use `set -euo pipefail`?
10. What is command substitution?
11. What is an if statement used for?
12. What is a loop?
13. Why use functions?
14. What does `>` do?
15. What does `>>` do?
16. What is a pipe?
17. Why validate script input?
18. How do you syntax-check Bash?
19. How do you trace Bash execution?
20. Why are scripts important in DevOps?

### Answer Key

1. A shell and scripting language.
2. It selects the interpreter.
3. Adds executable permission.
4. A named value.
5. First positional argument.
6. Number of arguments.
7. Previous command's exit status.
8. Success.
9. It provides safer error/unset-variable/pipeline behavior.
10. Capturing command output as a value.
11. Conditional execution.
12. Repeated execution.
13. Reuse and organization.
14. Overwrites/creates output.
15. Appends output.
16. Connects command output to another command's input.
17. To prevent invalid/unexpected execution.
18. `bash -n script.sh`.
19. `bash -x script.sh`.
20. It makes repeatable operational work consistent and scalable.

---

## 22. Bash Cheat Sheet

| Syntax/Command | Purpose |
|---|---|
| `#!/usr/bin/env bash` | Bash interpreter |
| `chmod +x` | Make executable |
| `$1` | First argument |
| `$#` | Argument count |
| `$?` | Previous exit status |
| `$(command)` | Command substitution |
| `if` | Conditional |
| `for` | Iteration |
| `while` | Conditional loop |
| `function_name()` | Function |
| `>` | Overwrite output |
| `>>` | Append output |
| `2>` | Redirect stderr |
| `|` | Pipe |
| `export` | Set exported variable |
| `exit` | End script with status |
| `bash -n` | Syntax check |
| `bash -x` | Trace execution |

---

## 23. Day 4 Final Checklist

- [ ] I can create a Bash script.
- [ ] I understand the shebang.
- [ ] I can use variables.
- [ ] I can accept arguments.
- [ ] I understand exit codes.
- [ ] I can write conditions.
- [ ] I can write loops.
- [ ] I can create functions.
- [ ] I can redirect output.
- [ ] I understand pipes.
- [ ] I can validate script input.
- [ ] I can debug Bash.
- [ ] I can automate a Linux health check.
- [ ] I understand why scripting matters in DevOps.

# DAY 4 COMPLETE

Next:

## DAY 5 — NETWORKING FUNDAMENTALS

**FOUNDATION OF MASTERING AUTOMATION**  
**Learn • Automate • Innovate • Elevate**

**William Foma — DevOps Trainer**  
**https://foma.life**
