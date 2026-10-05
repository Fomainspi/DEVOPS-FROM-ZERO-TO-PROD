# Day 19 — Jenkins & GitHub Actions

> **FOMA · William Foma**  
> **DEVOPS FROM ZERO TO PRODUCTION**  
> Build practical CI/CD pipelines with Jenkins and GitHub Actions.

---

## 1. Learning objectives

You will learn:

- what Jenkins and GitHub Actions do;
- workflows, jobs, steps and runners;
- Jenkins agents, stages and Jenkinsfiles;
- GitHub Actions triggers;
- dependencies, artifacts and secrets;
- production approvals;
- CI/CD security;
- troubleshooting techniques;
- how to choose between the two platforms.

---

## 2. Jenkins and GitHub Actions

Both tools automate software delivery.

### Jenkins

**Jenkins** is an automation server with a large plugin ecosystem.

### GitHub Actions

**GitHub Actions** is GitHub's native automation platform using workflow files stored in a repository.

### Analogy: two factories

Both factories can manufacture the same product.

Their machinery and control systems differ.

The transferable skill is understanding:

> trigger → runner/agent → steps → artifact → deployment → verification.

---

## 3. GitHub Actions mental model

A workflow typically looks like:

~~~text
Workflow
  |
  +-- Job
       |
       +-- Step
       +-- Step
       +-- Step
~~~

Example:

~~~yaml
name: CI

on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: python -m pytest
~~~

---

## 4. Workflow

### Definition

A **workflow** is an automated process defined in YAML under:

~~~text
.github/workflows/
~~~

A workflow can run on events such as:

- push;
- pull request;
- schedule;
- manual dispatch.

---

## 5. Job

### Definition

A **job** is a unit of work executed on a runner.

Example:

~~~yaml
jobs:
  test:
    runs-on: ubuntu-latest
~~~

A workflow may contain:

~~~text
test
build
security
deploy
~~~

Jobs can depend on each other.

---

## 6. Step

### Definition

A **step** is an individual action or shell command inside a job.

Example:

~~~yaml
steps:
  - uses: actions/checkout@v4
  - run: python -m pip install -r requirements.txt
  - run: pytest
~~~

### Analogy

Workflow = recipe.

Job = cooking station.

Step = individual instruction.

---

## 7. Runner

### Definition

A **runner** is the machine that executes a GitHub Actions job.

It can be:

- GitHub-hosted;
- self-hosted.

The runner provides the execution environment.

---

## 8. A practical GitHub Actions pipeline

~~~yaml
name: FOMA CI

on:
  pull_request:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.12"

      - name: Install
        run: pip install -r requirements.txt

      - name: Test
        run: pytest
~~~

This validates changes before deployment.

---

## 9. Job dependencies

Suppose:

~~~text
test
  |
  v
build
  |
  v
deploy
~~~

GitHub Actions can express this with:

~~~yaml
needs: test
~~~

Example:

~~~yaml
jobs:
  test:
    ...

  build:
    needs: test
    ...

  deploy:
    needs: build
    ...
~~~

This creates a controlled flow.

---

## 10. Artifacts

### Definition

A workflow artifact is a file or collection of files stored from a workflow run.

Examples:

- test reports;
- packaged applications;
- logs;
- build outputs.

An artifact is not the same thing as a container registry image.

A registry stores deployable images; workflow artifacts commonly store outputs from a particular run.

---

## 11. Secrets

Use repository or environment secret stores instead of hard-coding credentials.

For cloud deployments, prefer short-lived identity mechanisms where supported.

Never print credentials into logs.

---

## 12. Environments and approvals

Production can be protected with an environment.

Concept:

~~~text
Build
 |
 v
Staging
 |
 v
Approval
 |
 v
Production
~~~

This provides a deliberate control point before high-impact changes.

---

## 13. Jenkins Pipeline

### Definition

A **Jenkins Pipeline** describes automation as code.

A common declarative pipeline is stored in:

~~~text
Jenkinsfile
~~~

Example:

~~~groovy
pipeline {
    agent any

    stages {
        stage('Test') {
            steps {
                sh 'pytest'
            }
        }

        stage('Build') {
            steps {
                sh 'docker build -t foma-app:$BUILD_NUMBER .'
            }
        }
    }
}
~~~

---

## 14. Jenkins concepts

### Controller

Coordinates Jenkins automation.

### Agent

Executes pipeline work.

### Pipeline

Defines the delivery process.

### Stage

Logical section such as Test or Build.

### Step

Individual command/action.

### Plugin

Extends Jenkins.

### Analogy

Controller = operations manager.

Agent = worker.

Pipeline = production procedure.

Stage = department.

Step = task.

---

## 15. Jenkinsfile example

~~~groovy
pipeline {
    agent any

    environment {
        IMAGE = "foma-app"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Test') {
            steps {
                sh 'python -m pytest'
            }
        }

        stage('Build') {
            steps {
                sh "docker build -t $IMAGE:$BUILD_NUMBER ."
            }
        }
    }

    post {
        always {
            echo 'Pipeline completed.'
        }
    }
}
~~~

---

## 16. Jenkins vs GitHub Actions

| Area | Jenkins | GitHub Actions |
|---|---|---|
| Hosting | Often self-managed | GitHub platform |
| Pipeline as code | Jenkinsfile | YAML |
| Extensions | Large plugin ecosystem | Actions ecosystem |
| Execution | Agents | Runners |
| GitHub integration | Excellent | Native |
| Infrastructure control | High | Depends on runner model |

Neither is universally better.

Choose based on:

- organization;
- compliance;
- hosting requirements;
- existing platform;
- team skills;
- ecosystem.

---

## 17. Security practices

For either platform:

- minimize permissions;
- protect secrets;
- review third-party actions/plugins;
- protect production workflows;
- protect branches;
- avoid printing credentials;
- use short-lived credentials;
- isolate untrusted builds;
- control self-hosted runners carefully.

A CI/CD system can become a powerful production identity.

---

## 18. Troubleshooting GitHub Actions

### Workflow does not start

Check:

- trigger;
- branch;
- YAML syntax;
- repository permissions.

### Secret unavailable

Check:

- exact secret name;
- repository/environment scope;
- environment protection;
- permissions.

### Permission denied

Inspect the workflow permission model and grant only required scopes.

### Docker build fails

Check:

- Dockerfile;
- build context;
- dependency installation;
- runner resources.

---

## 19. Troubleshooting Jenkins

Check:

- Jenkins console output;
- agent availability;
- credentials;
- plugins;
- workspace;
- Docker permissions;
- environment variables.

A command working on a developer laptop does not guarantee it will work on the Jenkins agent.

---

## 20. Hands-on project

Build the same CI pipeline in both tools.

### GitHub Actions

Create:

~~~text
.github/workflows/ci.yml
~~~

Stages:

~~~text
Checkout
  ↓
Test
  ↓
Build
  ↓
Artifact
~~~

### Jenkins

Create:

~~~text
Jenkinsfile
~~~

Stages:

~~~text
Checkout
  ↓
Test
  ↓
Build
~~~

Compare the implementations.

---

## 21. Knowledge check

1. What is a GitHub Actions workflow?
2. What is a job?
3. What is a step?
4. What is a runner?
5. What is Jenkins?
6. What is a Jenkinsfile?
7. What is an agent?
8. How do jobs depend on each other?
9. Why use environment protection?
10. Why minimize CI credentials?
11. What is an artifact?
12. Why can a pipeline fail on a runner but work locally?

### Answers

1. An automated process defined in YAML.
2. A unit of execution.
3. An individual action or command.
4. The machine executing the job.
5. An automation server/platform.
6. Pipeline-as-code definition for Jenkins.
7. A machine executing Jenkins work.
8. Through dependencies such as needs or pipeline stage flow.
9. To protect sensitive deployment environments.
10. CI systems can access valuable source and production resources.
11. Stored output from a workflow run.
12. Runner environments and dependencies can differ.

---

## 22. Day 19 challenge

Implement the same application pipeline using:

1. GitHub Actions;
2. Jenkins.

Both must:

- test;
- build;
- produce an artifact or image;
- fail when tests fail;
- expose useful logs;
- keep credentials out of source code.

### FOMA takeaway

> **Tools change, but CI/CD fundamentals remain: trigger, execute, validate, package, deploy and verify.**

**Learn • Practice • Build • Troubleshoot • Advance**

https://foma.life
