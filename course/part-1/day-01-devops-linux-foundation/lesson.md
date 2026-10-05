# DEVOPS FROM ZERO TO PRODUCTION

## PART 1 — DEVOPS & LINUX FOUNDATION
## DAY 1 — DEVOPS & LINUX FOUNDATION

**FOUNDATION OF MASTERING AUTOMATION (FOMA)**  
**Trainer:** William Foma — DevOps Trainer  
**Website:** https://foma.life

> Learn • Automate • Innovate • Elevate

---

# 1. DAY 1 — THE FOUNDATION

Welcome to **DEVOPS FROM ZERO TO PRODUCTION**.

This first lesson establishes the foundation required for the rest of the program. Before Docker, Kubernetes, Terraform, CI/CD, AWS, monitoring, and production automation, a DevOps engineer needs to understand:

- what DevOps is
- why Linux matters
- how to use the Linux terminal
- how Linux organizes files
- how permissions work
- how users and groups work
- how processes work
- how packages are managed
- how to troubleshoot using evidence

The learning progression is:

**BEGINNER → UNDERSTAND → HANDS-ON → TROUBLESHOOT → DEVOPS APPLICATION**

The goal is not to memorize commands. The goal is to understand what the system is telling you.

---

# 2. LEARNING OBJECTIVES

By the end of Day 1, you should be able to:

1. Explain what DevOps is.
2. Explain why DevOps matters.
3. Describe the DevOps lifecycle.
4. Explain Development and Operations.
5. Explain why Linux is fundamental to DevOps.
6. Use a Linux terminal.
7. Understand shell, terminal, command, and prompt.
8. Navigate the Linux filesystem.
9. Explain important Linux directories.
10. Distinguish absolute and relative paths.
11. Create, inspect, copy, move, rename, and delete files/directories.
12. Read and search files.
13. Inspect logs.
14. Understand Linux permissions.
15. Understand users, groups, UID, and GID.
16. Inspect running processes and PIDs.
17. Understand basic Ubuntu/Debian package management.
18. Perform a basic troubleshooting workflow.
19. Complete the Day 1 hands-on project.

---

# 3. LAB ENVIRONMENT AND SAFETY

Recommended:

- Ubuntu LTS virtual machine
- Ubuntu WSL2
- Disposable Linux cloud VM
- Another Linux distribution for additional practice

Use a safe lab directory:

    mkdir -p ~/devops-day1
    cd ~/devops-day1
    pwd

Expected pattern:

    /home/<your-user>/devops-day1

Your username will differ.

## Commands requiring extra care

    rm
    rm -r
    rm -rf
    sudo
    chmod
    chown
    kill
    kill -9

Professional rule:

> Never execute a powerful command simply because someone told you to copy and paste it. Understand the command and its target first.

---

# 4. WHAT IS DEVOPS?

## 4.1 Definition

**DevOps is a culture and set of practices that brings software development and IT operations together through collaboration, automation, continuous delivery, monitoring, feedback, and continuous improvement.**

DevOps is not a single tool.

It is not Jenkins.

It is not Docker.

It is not Kubernetes.

It is not AWS.

Those technologies can support DevOps practices.

A useful model is:

    DEVOPS
       |
       +---- Culture
       |
       +---- Collaboration
       |
       +---- Automation
       |
       +---- CI/CD
       |
       +---- Infrastructure as Code
       |
       +---- Monitoring
       |
       +---- Feedback
       |
       +---- Continuous Improvement

## 4.2 Development

Development teams build and change software.

Typical activities:

- writing code
- implementing features
- fixing defects
- writing tests
- code reviews
- packaging applications

## 4.3 Operations

Operations teams run and maintain systems.

Typical activities:

- servers
- deployments
- availability
- monitoring
- security
- backups
- incident response
- capacity management

## 4.4 Traditional silo model

A simplified traditional workflow can look like:

    Developer
        |
        | "It works on my machine."
        v
    Operations
        |
        | "It fails in production."
        v
    Developer
        |
        +---- delays
        +---- manual work
        +---- deployment risk
        +---- unclear ownership

DevOps improves collaboration and shared responsibility instead of creating blame.

## 4.5 Modern DevOps model

    PLAN
      |
    CODE
      |
    BUILD
      |
    TEST
      |
    RELEASE
      |
    DEPLOY
      |
    OPERATE
      |
    MONITOR
      |
    FEEDBACK
      |
      +--------------> PLAN

This is a continuous loop.

---

# 5. DEVOPS LIFECYCLE

## 5.1 PLAN

Planning defines what should be built or changed.

Activities:

- requirements
- user stories
- priorities
- acceptance criteria
- architecture
- risks

Possible tools:

- Jira
- GitHub Issues
- Azure Boards

## 5.2 CODE

Engineers implement the change.

Activities:

- source code
- branches
- pull requests
- code reviews
- version control

Possible tools:

- Git
- GitHub
- GitLab

## 5.3 BUILD

The build process transforms source code into a deployable artifact.

Examples:

    Java source       -> JAR
    TypeScript        -> JavaScript
    Application code  -> Container image

Possible tools:

- Maven
- Gradle
- npm
- Docker

## 5.4 TEST

Testing verifies expected behavior.

Examples:

- unit tests
- integration tests
- end-to-end tests
- security tests
- regression tests

Possible tools:

- JUnit
- pytest
- Selenium

## 5.5 RELEASE

Release prepares a tested version for delivery.

Activities:

- versioning
- artifact management
- approvals
- release notes
- change records

Possible tools:

- GitHub Actions
- Jenkins
- GitLab CI/CD

## 5.6 DEPLOY

Deployment moves software into an environment.

Examples:

- development
- staging
- production

Possible tools:

- Docker
- Kubernetes
- Argo CD
- cloud deployment services

## 5.7 OPERATE

The application must remain available and healthy.

Activities:

- service management
- configuration
- scaling
- backups
- incident response

## 5.8 MONITOR

Monitoring provides evidence about system behavior.

Examples:

- CPU
- memory
- latency
- request rate
- error rate
- disk usage
- application health

Possible tools:

- Prometheus
- Grafana
- Loki
- cloud monitoring platforms

## 5.9 FEEDBACK

Feedback can come from:

- users
- metrics
- logs
- incidents
- support
- tests
- business results

Feedback starts the next planning cycle.

---

# 6. WHY LINUX?

Linux is widely used for:

- servers
- cloud infrastructure
- web servers
- databases
- container hosts
- CI/CD runners
- Kubernetes nodes
- automation
- monitoring
- infrastructure tooling

A DevOps engineer frequently investigates what is happening inside Linux.

## Linux in a modern platform

    Developer
        |
    Application
        |
    Container
        |
    Linux Host
        |
    Kubernetes Node
        |
    Cloud Infrastructure

Linux can appear at multiple layers.

## Why the command line matters

Production infrastructure is often remote.

A DevOps engineer may connect through SSH and work entirely from a terminal.

    Laptop
      |
      | SSH
      v
    Linux Server
      |
      +---- files
      +---- logs
      +---- processes
      +---- permissions
      +---- packages
      +---- configuration

The terminal is an engineering interface.

---

# 7. TERMINAL FUNDAMENTALS

## 7.1 Terminal

A terminal is an interface for interacting with a computer through text commands.

## 7.2 Shell

A shell interprets commands.

Common shells:

- Bash
- Zsh
- Fish

This course uses Bash-style examples.

## 7.3 Command

A command is an instruction given to the shell.

Example:

    pwd

## 7.4 Understanding the prompt

Example:

    user@server:~$

Breakdown:

    user      = username
    server    = hostname
    ~         = current user's home directory
    $         = normal-user prompt

A root prompt commonly looks like:

    root@server:~#

The exact appearance is configurable, so the prompt itself is not a security control.

## 7.5 sudo

Administrative commands may require:

    sudo <command>

Example:

    sudo apt update

Do not use sudo simply because a command failed. First understand why it failed.

---

# 8. LINUX FILESYSTEM HIERARCHY

Linux uses a single filesystem tree beginning at:

    /

Simplified structure:

    /
    ├── bin
    ├── boot
    ├── dev
    ├── etc
    ├── home
    ├── lib
    ├── media
    ├── mnt
    ├── opt
    ├── proc
    ├── root
    ├── run
    ├── sbin
    ├── srv
    ├── sys
    ├── tmp
    ├── usr
    └── var

Modern Linux distributions may implement traditional directories such as /bin as links into /usr. Learn the purpose of a directory rather than assuming one implementation.

## 8.1 /

Filesystem root.

Everything is located somewhere below it.

## 8.2 /home

Home directories for normal users.

Examples:

    /home/will
    /home/alice
    /home/bob

## 8.3 /root

Home directory of the root account.

Remember:

    /       = filesystem root
    /root   = root user's home

## 8.4 /etc

Common location for system and application configuration.

Examples may include:

    /etc/hosts
    /etc/ssh/
    /etc/systemd/
    /etc/nginx/

The exact contents depend on the system.

## 8.5 /var

Variable system and application data.

Important examples:

    /var/log
    /var/lib
    /var/cache

## 8.6 /var/log

Logs provide evidence about system and application behavior.

## 8.7 /var/lib

Applications and system components may store persistent state here.

Do not delete unfamiliar data from /var/lib.

## 8.8 /tmp

Temporary data.

Do not assume temporary files are permanent.

## 8.9 /usr

Common location for programs, libraries, documentation, and shared data.

Examples:

    /usr/bin
    /usr/sbin
    /usr/lib
    /usr/share

## 8.10 /opt

Common location for optional/add-on software.

## 8.11 /boot

Contains boot-related files on systems using this layout.

## 8.12 /dev

Contains device nodes and special files.

## 8.13 /proc

Virtual filesystem exposing process and kernel information.

Example:

    ls /proc
    cat /proc/cpuinfo

## 8.14 /sys

Virtual filesystem exposing kernel/device information.

## 8.15 /var/www

Common web-server document-root location, but not mandatory. The actual web root depends on web-server configuration.

## DevOps troubleshooting connection

    Application problem
           |
    Check configuration
           |
       /etc or app config
           |
       Check logs
           |
    /var/log or app logging
           |
      Check process
           |
    ps / top / systemctl
           |
    Check permissions
           |
         Diagnose

---

# 9. PATHS: ABSOLUTE AND RELATIVE

## 9.1 Absolute path

An absolute path starts from /.

Example:

    /home/will/devops-day1/app.log

## 9.2 Relative path

A relative path is interpreted from the current directory.

If:

    pwd
    /home/will/devops-day1

then:

    ./app.log

means:

    /home/will/devops-day1/app.log

## 9.3 Dot notation

    .   = current directory
    ..  = parent directory

Example:

    cd ..

moves one level upward.

## 9.4 Visual example

    /home/will/devops-day1/
    ├── app/
    │   └── index.html
    └── logs/
        └── app.log

From devops-day1:

    app/index.html

is relative.

    /home/will/devops-day1/app/index.html

is absolute.

---

# 10. ESSENTIAL LINUX COMMANDS

For every command learn:

1. purpose
2. syntax
3. example
4. expected result
5. common mistakes
6. DevOps use

## 10.1 pwd

Purpose: show the current working directory.

    pwd

Example:

    $ pwd
    /home/will/devops-day1

Why it matters:

Before changing files or configuration, know where you are.

## 10.2 ls

List directory contents.

    ls
    ls -l
    ls -la

Meaning:

- -l = long listing
- -a = include hidden entries

## 10.3 cd

Change directory.

    cd /var/log
    cd ..
    cd ~
    cd /
    cd -

## 10.4 mkdir

Create a directory.

    mkdir devops-lab

Create nested directories:

    mkdir -p project/app/logs

## 10.5 touch

Create an empty file if it does not exist.

    touch file.txt

If the file already exists, touch updates timestamps rather than clearing content.

## 10.6 cp

Copy.

    cp file.txt backup.txt
    cp file.txt backup/
    cp -r app app-backup

## 10.7 mv

Move or rename.

    mv file.txt newname.txt
    mv file.txt archive/

## 10.8 rm

Remove.

    rm file.txt
    rm -r directory

WARNING: rm is not a normal recycle-bin operation.

## 10.9 cat

Display a file.

    cat file.txt

Good for small files.

## 10.10 less

View a file page by page.

    less app.log

Common controls:

- Space = next page
- b = previous page
- / = search
- q = quit

## 10.11 head

Show the beginning.

    head file.txt
    head -n 20 file.txt

## 10.12 tail

Show the end.

    tail file.txt
    tail -n 20 file.txt
    tail -f app.log

Stop tail -f with Ctrl+C.

## 10.13 grep

Search text.

    grep "ERROR" app.log
    grep -i "error" app.log
    grep -n "ERROR" app.log
    grep -r "ERROR" logs/

Flags:

- -i = case-insensitive
- -n = line number
- -r = recursive

---

# 11. HANDS-ON FILE MANAGEMENT LAB

Start safely:

    cd ~/devops-day1

Create the lab:

    mkdir devops-lab
    cd devops-lab

Create files:

    touch file1.txt
    touch file2.txt
    touch file3.txt
    ls -la

Create archive:

    mkdir archive

Copy:

    cp file1.txt archive/

Move:

    mv file2.txt archive/

Rename:

    mv file3.txt file3-renamed.txt

Verify:

    ls -la
    ls -la archive

Expected structure:

    devops-lab/
    ├── archive/
    │   ├── file1.txt
    │   └── file2.txt
    └── file3-renamed.txt

Optional verification:

    find . -maxdepth 2 -type f -print

---

# 12. WRITING AND READING FILES

## 12.1 Overwrite/create with >

    echo "Hello DevOps" > file.txt
    cat file.txt

Expected:

    Hello DevOps

The > operator normally replaces existing content.

## 12.2 Append with >>

    echo "Line 1" > app.log
    echo "Line 2" >> app.log
    cat app.log

Output:

    Line 1
    Line 2

Remember:

    >   = replace/create
    >>  = append/create

This distinction becomes important in Bash scripting and automation.

---

# 13. LOGS AND TROUBLESHOOTING

Logs are evidence.

A disciplined troubleshooting loop is:

    PROBLEM
       |
    OBSERVE
       |
    COLLECT EVIDENCE
       |
    FORM HYPOTHESIS
       |
    TEST
       |
    FIX
       |
    VERIFY
       |
    DOCUMENT

## Example log

    INFO Application started
    INFO Listening on port 8080
    ERROR Database connection failed
    INFO Retry started
    ERROR Database timeout

Find errors:

    grep "ERROR" app.log

## Reading logs

Small file:

    cat app.log

Large file:

    less app.log

Recent entries:

    tail -n 50 app.log

Follow new entries:

    tail -f app.log

## /var/log/syslog

Some Linux systems using syslog may have:

    /var/log/syslog

Do not assume every Linux distribution uses this exact file.

Modern environments may use:

- systemd journal
- rsyslog
- application-specific files
- container logging
- centralized cloud logging

Always identify the logging system before assuming a path.

---

# 14. SEARCHING WITH GREP

Given:

    INFO Application started
    INFO Listening on port 8080
    ERROR Database connection failed
    INFO Retry started
    ERROR Database timeout

Run:

    grep "ERROR" app.log

Result:

    ERROR Database connection failed
    ERROR Database timeout

## Case-insensitive

    grep -i "error" app.log

## Line numbers

    grep -n "ERROR" app.log

Example:

    3:ERROR Database connection failed
    5:ERROR Database timeout

## Recursive

    grep -r "ERROR" logs/

## Search for a connection failure

    grep -i "connection refused" app.log

Possible causes include:

- target service unavailable
- wrong hostname
- wrong port
- firewall
- network failure
- DNS problem
- application configuration error

One log message is evidence, not automatically the root cause.

## Avoid unnecessary pipelines

This works:

    cat app.log | grep ERROR

But this is simpler:

    grep ERROR app.log

Professional habit:

> Prefer the simplest command that directly answers the question.

---

# 15. LINUX FILE PERMISSIONS

Permissions answer:

> Who is allowed to do what?

Run:

    ls -l file.txt

Example:

    -rw-r--r-- 1 user user 1024 Sep 25 10:00 file.txt

## Permission anatomy

    -rw-r--r--
    │ │  │  │
    │ │  │  └── others
    │ │  └───── group
    │ └──────── owner
    └────────── file type

Permissions:

    r = read
    w = write
    x = execute

Groups:

    owner | group | others

Example:

    rw- | r-- | r--

Meaning:

- owner = read/write
- group = read
- others = read

## Numeric permissions

    read    = 4
    write   = 2
    execute = 1

Therefore:

    7 = rwx
    6 = rw-
    5 = r-x
    4 = r--
    3 = -wx
    2 = -w-
    1 = --x
    0 = ---

## chmod 755

    chmod 755 script.sh

Means:

    owner  = rwx
    group  = r-x
    others = r-x

## chmod 644

    chmod 644 file.txt

Means:

    owner  = rw-
    group  = r--
    others = r--

## chown

    sudo chown user:user file.txt

Changes the owner and group.

WARNING: do not change ownership of system files without understanding the impact.

## Directory permissions

For directories:

- r = list entries
- w = create/remove/rename entries when other requirements are satisfied
- x = traverse/access entries by name

Directory permissions therefore behave differently from ordinary file permissions.

---

# 16. USERS AND GROUPS

Linux uses identities to control access.

## whoami

    whoami

Shows the current effective username.

## id

    id

Example pattern:

    uid=1000(will) gid=1000(will) groups=1000(will),27(sudo)

Your values will differ.

UID = User ID.

GID = Group ID.

## groups

    groups

Shows group memberships.

## Why DevOps engineers care

Identity affects:

- SSH access
- file ownership
- application permissions
- service accounts
- CI/CD runners
- container processes
- Kubernetes security contexts

## sudo

    sudo apt update

Use administrative privileges only when required.

---

# 17. PROCESS MANAGEMENT

## 17.1 Program versus process

A program is executable code.

A process is a running instance of a program.

Example:

    nginx program
         |
    running process
         |
       PID 1234

PID = Process ID.

## 17.2 ps

    ps
    ps aux

Use ps to inspect running processes.

## 17.3 Search for nginx

    ps aux | grep nginx

The pipe sends the output of ps to grep.

A simple grep can also match the grep process itself. More advanced lessons will introduce tools such as pgrep.

## 17.4 top

    top

Provides a continuously updating process/resource view.

Exit with q.

## 17.5 htop

If installed:

    htop

Install on Ubuntu/Debian if needed:

    sudo apt install htop

## 17.6 kill

Suppose the PID is 1234:

    kill 1234

By default, this sends SIGTERM, requesting graceful termination.

## 17.7 kill -9

    kill -9 1234

Signal 9 is SIGKILL.

SIGKILL forcefully terminates the process and does not allow normal cleanup.

Professional rule:

> Prefer graceful termination first. Use SIGKILL as a last resort.

---

# 18. UBUNTU/DEBIAN PACKAGE MANAGEMENT

Ubuntu/Debian commonly use APT.

## apt update

    sudo apt update

This refreshes package metadata.

It does not mean every installed package has been upgraded.

## apt upgrade

    sudo apt upgrade

Attempts to upgrade installed packages using the available package metadata and dependency rules.

Think:

    apt update
         |
    refresh information
         |
    apt upgrade
         |
    apply available upgrades

## Install nginx

    sudo apt update
    sudo apt install nginx

Verify:

    nginx -v

You can inspect the service on systemd-based systems:

    systemctl status nginx

Systemd administration is covered in a later lesson.

## Remove nginx

    sudo apt remove nginx

Use package removal carefully on real systems.

---

# 19. REAL-WORLD DEVOPS WORKFLOW

Scenario:

A company reports that its web application is returning errors.

A beginner might restart everything.

A DevOps engineer starts with evidence.

## Step 1 — Identity

    whoami
    id

## Step 2 — Location

    pwd
    ls -la

## Step 3 — Application files

Example:

    ls -la /var/www/app

The actual path depends on the application.

## Step 4 — Logs

    tail -n 50 /path/to/application.log

## Step 5 — Search

    grep -i "error" /path/to/application.log

## Step 6 — Process

    ps aux | grep nginx

## Step 7 — Permissions

    ls -l /var/www/app

## Step 8 — Form a hypothesis

Suppose the log says:

    ERROR Database connection refused

Possible hypotheses:

- database unavailable
- wrong hostname
- wrong port
- network problem
- firewall
- DNS issue
- configuration error
- database startup delay

Do not immediately assume the database is down.

## Step 9 — Test

Choose the next test that can distinguish between your hypotheses.

## Step 10 — Verify

After a change:

1. reproduce the problem
2. verify expected behavior
3. inspect logs
4. inspect metrics where available
5. document the change

This is evidence-driven operations.

---

# 20. COMMON BEGINNER MISTAKES

## Mistake 1 — Not checking the current directory

Before destructive operations:

    pwd
    ls -la

## Mistake 2 — Confusing / and ~

    /  = filesystem root
    ~  = current user's home

## Mistake 3 — Treating rm like a recycle bin

rm normally removes the directory entry directly rather than sending it to a graphical recycle bin.

## Mistake 4 — Using sudo for everything

More privilege means more impact when a mistake occurs.

## Mistake 5 — Using rm -rf without understanding it

Recursive deletion can remove an entire directory tree.

## Mistake 6 — Confusing > and >>

    >   = replace/create
    >>  = append/create

## Mistake 7 — Ignoring permissions

Applications can fail because they cannot read, write, or traverse required paths.

## Mistake 8 — Assuming all Linux systems have identical paths

Distributions, installed software, and logging architectures differ.

## Mistake 9 — Killing the wrong PID

Always verify the process before sending a signal.

## Mistake 10 — Editing important configuration without a backup

For a lab file:

    cp config.conf config.conf.bak

In production, prefer version-controlled or configuration-managed workflows where appropriate.

---

# 21. TROUBLESHOOTING MINI-LAB

## Scenario

An Nginx-backed web application is reported as unhealthy.

Your objective is to collect evidence without randomly restarting services.

## Task 1 — Identity

    whoami
    id
    groups

Questions:

- Which user are you?
- What is your UID?
- What is your GID?
- What groups are you in?

## Task 2 — Location

    pwd
    ls -la

Question:

Are you in the expected directory?

## Task 3 — Process

    ps aux | grep nginx

Question:

Is Nginx running?

Remember that a simple grep may also display the grep command itself.

## Task 4 — Logs

    ls -la /var/log

If Nginx is installed, logs may be under:

    /var/log/nginx/

Inspect:

    ls -la /var/log/nginx
    tail -n 50 /var/log/nginx/error.log

## Task 5 — Search

    grep -i "error" /var/log/nginx/error.log

## Task 6 — Permissions

If the application is under /var/www:

    ls -la /var/www
    ls -la /var/www/<application>

Determine:

- owner
- group
- permissions
- whether the service can traverse/read required paths

## Task 7 — Incident note

Write:

    Observed:
    Evidence:
    Likely cause:
    Next test:
    Action:
    Verification:

The goal is not to guess.

The goal is to demonstrate a repeatable troubleshooting method.

---

# 22. DAY 1 PRACTICE CHALLENGE

## Mission

Build:

    devops-lab/
    ├── app/
    │   ├── app.conf
    │   └── index.html
    ├── logs/
    │   └── app.log
    ├── backup/
    └── scripts/
        └── healthcheck.sh

## Step 1 — Create directories

    cd ~/devops-day1
    mkdir -p devops-lab/app
    mkdir -p devops-lab/logs
    mkdir -p devops-lab/backup
    mkdir -p devops-lab/scripts
    cd devops-lab

Verify:

    ls -la

## Step 2 — Create files

    touch app/app.conf
    touch app/index.html
    touch logs/app.log
    touch scripts/healthcheck.sh

## Step 3 — Add realistic content

    echo "APP_NAME=devops-demo" > app/app.conf
    echo "DevOps Application" > app/index.html
    echo "INFO Application started" > logs/app.log
    echo "ERROR Database connection failed" >> logs/app.log
    echo "INFO Application retry started" >> logs/app.log

## Step 4 — Search

    grep -n "ERROR" logs/app.log

Expected pattern:

    2:ERROR Database connection failed

## Step 5 — Backup

    cp app/app.conf backup/
    ls -la backup

## Step 6 — Rename

    mv app/index.html app/home.html
    ls -la app

## Step 7 — Permissions

    ls -l scripts/healthcheck.sh
    chmod 755 scripts/healthcheck.sh
    ls -l scripts/healthcheck.sh

## Step 8 — Identity

    whoami
    id
    groups

## Step 9 — Processes

    ps aux | head

If available:

    top

Exit top with q.

## Step 10 — Verify

    find . -maxdepth 3 -print

Expected structure:

    .
    ./app
    ./app/app.conf
    ./app/home.html
    ./logs
    ./logs/app.log
    ./backup
    ./backup/app.conf
    ./scripts
    ./scripts/healthcheck.sh

## Challenge questions

1. Why did we use mkdir -p?
2. What did > do?
3. What did >> do?
4. Why did we create a backup?
5. What changed when we used chmod 755?
6. Why did we use grep -n?
7. Why should logs be investigated before randomly restarting services?
8. What is the difference between a program and a process?
9. What does a PID identify?
10. Why can an application be unhealthy even when its process is running?

---

# 23. KNOWLEDGE CHECK

## Multiple Choice

1. What is the primary idea behind DevOps?

A. Replace developers with automation  
B. Use only cloud technologies  
C. Improve collaboration, automation, delivery, operations, and feedback  
D. Eliminate operations teams

2. What does pwd show?

A. Password  
B. Current working directory  
C. Running processes  
D. Package versions

3. Which command lists hidden files in long format?

A. ls -x  
B. ls -la  
C. list --hidden  
D. show -all

4. What does cd .. do?

A. Goes home  
B. Goes to root  
C. Moves to the parent directory  
D. Deletes the current directory

5. What does ~ normally represent?

A. Filesystem root  
B. Current user's home directory  
C. Temporary directory  
D. Always /root

6. Which directory commonly contains system configuration?

A. /etc  
B. /tmp  
C. /media  
D. /proc

7. Which directory commonly contains variable system data?

A. /boot  
B. /var  
C. /dev  
D. /home

8. What does grep primarily do?

A. Copy files  
B. Search text  
C. Start processes  
D. Install packages

9. What does >> generally do?

A. Deletes a file  
B. Appends output  
C. Executes as root  
D. Changes permissions

10. What does x mean in normal file permissions?

A. Delete  
B. Execute  
C. Compress  
D. Encrypt

11. What does chmod 755 script.sh generally grant?

A. Everyone write access  
B. Owner rwx, group r-x, others r-x  
C. Owner read only  
D. No permissions

12. What is a PID?

A. Package Identifier  
B. Process ID  
C. Permission ID  
D. Project ID

13. Which command provides a process snapshot?

A. ps  
B. apt  
C. chmod  
D. mkdir

14. Which command provides an interactive process view?

A. touch  
B. top  
C. cat  
D. mv

15. What does kill PID normally send?

A. SIGTERM  
B. SIGKILL  
C. SIGSTOP  
D. No signal

16. What does kill -9 PID send?

A. SIGTERM  
B. SIGKILL  
C. SIGSTOP  
D. SIGUSR1

17. What does apt update do?

A. Removes packages  
B. Refreshes package metadata  
C. Reboots the server  
D. Upgrades every package

18. What does whoami show?

A. All users  
B. Current effective username  
C. Current process  
D. Current hostname only

19. What does id help inspect?

A. User and group identity  
B. File contents  
C. Package repositories  
D. Network routes

20. Which troubleshooting method is best?

A. Restart everything  
B. Guess the root cause  
C. Collect evidence, form a hypothesis, test, fix, and verify  
D. Delete logs

## True or False

21. DevOps is a single software product.

22. Linux commands are useful for remote server administration.

23. / and ~ always represent the same location.

24. rm normally sends deleted files to a recycle bin.

25. Permissions control access to files and directories.

26. A running process has a PID.

27. apt update and apt upgrade mean the same thing.

28. SIGKILL is more forceful than SIGTERM.

29. Logs are useful evidence during troubleshooting.

30. A running process automatically proves an application is healthy.

## Short Answer

31. Explain DevOps in your own words.

32. Explain Development versus Operations.

33. Explain absolute versus relative paths.

34. Explain rw-r--r--.

35. Why should sudo be used carefully?

36. What is the difference between a program and a process?

37. Why would you use tail -f?

38. Why is grep useful to a DevOps engineer?

39. Why can Linux log locations differ?

40. Describe a basic production troubleshooting workflow.

---

# 24. ANSWER KEY

## Multiple Choice

1. C
2. B
3. B
4. C
5. B
6. A
7. B
8. B
9. B
10. B
11. B
12. B
13. A
14. B
15. A
16. B
17. B
18. B
19. A
20. C

## True/False

21. False — DevOps is a culture and set of practices supported by technology.

22. True.

23. False — / is filesystem root; ~ normally represents the current user's home.

24. False — rm is not a normal recycle-bin mechanism.

25. True.

26. True.

27. False — update refreshes metadata; upgrade applies available package upgrades.

28. True.

29. True.

30. False — a process can be alive while the application is unhealthy.

## Short-answer guidance

31. Mention collaboration, automation, delivery, operations, monitoring, feedback, and continuous improvement.

32. Development primarily creates/changes software; Operations primarily runs and maintains systems. DevOps improves collaboration and shared responsibility.

33. Absolute paths start at /; relative paths are interpreted from the current directory.

34. Owner can read/write; group can read; others can read.

35. sudo grants elevated privileges and therefore increases the impact of mistakes.

36. A program is executable code; a process is a running instance.

37. tail -f follows a changing file and is useful for live logs.

38. grep filters text so engineers can quickly find errors, warnings, IDs, or other evidence.

39. Linux distributions, services, logging daemons, containers, and cloud logging architectures differ.

40. Identify the symptom, collect evidence, inspect logs/processes/configuration/permissions, form a hypothesis, test it, apply a controlled fix, verify, and document.

---

# 25. COMMAND CHEAT SHEET

| Command | Purpose | Example | DevOps Use |
|---|---|---|---|
| pwd | Current directory | pwd | Confirm location |
| ls | List files | ls | Inspect files |
| ls -la | Detailed + hidden | ls -la | Inspect metadata |
| cd | Change directory | cd /var/log | Navigate |
| mkdir | Create directory | mkdir app | Build structure |
| touch | Create/update file timestamp | touch app.log | Create files |
| cp | Copy | cp app.conf backup/ | Backup |
| mv | Move/rename | mv old new | Organize |
| rm | Remove | rm file.txt | Cleanup |
| cat | Display | cat config | Inspect small files |
| less | Page through | less app.log | Large logs |
| head | First lines | head app.log | Inspect beginning |
| tail | Last lines | tail app.log | Recent logs |
| tail -f | Follow | tail -f app.log | Live logs |
| grep | Search | grep ERROR app.log | Troubleshoot |
| chmod | Permissions | chmod 755 script.sh | Access control |
| chown | Ownership | sudo chown user:user file | Ownership |
| whoami | Current user | whoami | Identity |
| id | UID/GID/groups | id | Access troubleshooting |
| groups | Group membership | groups | Permission checks |
| ps | Process snapshot | ps aux | Process troubleshooting |
| top | Interactive process view | top | CPU/memory |
| htop | Interactive process view | htop | Process analysis |
| kill | Send signal | kill 1234 | Graceful termination |
| kill -9 | SIGKILL | kill -9 1234 | Last resort |
| apt update | Refresh metadata | sudo apt update | Package maintenance |
| apt install | Install | sudo apt install nginx | Install software |
| apt remove | Remove | sudo apt remove nginx | Remove software |
| apt upgrade | Upgrade | sudo apt upgrade | Patch systems |

---

# 26. DAY 1 COMPLETION CHECKLIST

Before moving to Day 2:

- [ ] I can explain DevOps.
- [ ] I understand Development and Operations.
- [ ] I can describe the DevOps lifecycle.
- [ ] I understand why Linux matters.
- [ ] I understand terminal versus shell.
- [ ] I can read a Linux prompt.
- [ ] I can use pwd.
- [ ] I can use ls and ls -la.
- [ ] I can navigate with cd.
- [ ] I understand . and ..
- [ ] I understand absolute and relative paths.
- [ ] I understand /etc, /home, /tmp, /usr, and /var.
- [ ] I can create files and directories.
- [ ] I can copy and move files.
- [ ] I can safely remove lab files.
- [ ] I can read files.
- [ ] I can inspect logs.
- [ ] I can search logs with grep.
- [ ] I understand permissions.
- [ ] I understand UID and GID.
- [ ] I can identify users and groups.
- [ ] I can inspect processes.
- [ ] I understand PID.
- [ ] I understand SIGTERM versus SIGKILL.
- [ ] I understand apt update versus apt upgrade.
- [ ] I completed the troubleshooting lab.
- [ ] I completed the Day 1 challenge.
- [ ] I completed the knowledge check.

---

# 27. CONNECTION TO DAY 2

Day 1 establishes the foundation.

The learning path continues:

    DAY 1
    DevOps + Linux Foundation
          |
    DAY 2
    Linux Administration
          |
    DAY 3
    Git & GitHub
          |
    DAY 4
    Bash Scripting
          |
    DAY 5
    Networking
          |
    DAY 6+
    Docker -> Kubernetes -> CI/CD -> Terraform -> Cloud
          |
       PRODUCTION

Later technologies depend on these fundamentals.

Examples:

- Docker requires Linux process and filesystem knowledge.
- Kubernetes requires Linux and networking knowledge.
- CI/CD requires command-line and automation skills.
- Terraform requires infrastructure concepts.
- Production troubleshooting requires logs, processes, permissions, and networking.
- DevSecOps requires understanding the systems being secured.

---

# 28. REFERENCES

- Linux Foundation — Filesystem Hierarchy Standard: https://refspecs.linuxfoundation.org/fhs/
- GNU Coreutils manual: https://www.gnu.org/software/coreutils/manual/
- Local Linux manual pages: man ls, man grep, man chmod, man ps, man kill

---

# DAY 1 COMPLETE

You have taken your first step toward becoming a professional DevOps Engineer.

You did not simply learn Linux commands.

You learned how a DevOps engineer begins to **observe, understand, troubleshoot, and operate a system**.

## NEXT

### DAY 2 — LINUX ADMINISTRATION

---

**FOUNDATION OF MASTERING AUTOMATION**

**William Foma — DevOps Trainer**

**Learn • Automate • Innovate • Elevate**

https://foma.life

---

© Foundation of Mastering Automation (FOMA)
