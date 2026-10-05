# Day 18 — CI/CD Fundamentals

> **FOMA · William Foma**  
> **DEVOPS FROM ZERO TO PRODUCTION**  
> Turn code changes into reliable, repeatable delivery.

---

## 1. Learning objectives

You will learn:

- what CI means;
- what Continuous Delivery means;
- what Continuous Deployment means;
- how a pipeline works;
- what artifacts are;
- how environments and approvals work;
- what quality gates are;
- how security fits into delivery;
- common deployment strategies;
- how CI/CD connects Git, Docker, Kubernetes and cloud.

---

## 2. The problem CI/CD solves

Without automation:

~~~text
Developer
   |
   v
Build manually
   |
   v
Test manually
   |
   v
Copy files
   |
   v
Deploy manually
   |
   v
Hope nothing was missed
~~~

This is slow and inconsistent.

With CI/CD:

~~~text
Git push
   |
   v
Build
   |
   v
Test
   |
   v
Security
   |
   v
Package
   |
   v
Deploy
   |
   v
Verify
~~~

### Analogy: factory production line

A factory does not rely on workers remembering every manufacturing step.

It uses a repeatable production line.

A CI/CD pipeline is a software production line.

---

## 3. Continuous Integration

### Definition

**Continuous Integration (CI)** means integrating code changes frequently and automatically validating them.

A CI pipeline may run:

~~~text
Commit
  |
  v
Checkout
  |
  v
Dependencies
  |
  v
Lint
  |
  v
Tests
  |
  v
Build
  |
  v
Security checks
~~~

CI answers:

> **Is this change safe enough to continue?**

---

## 4. Continuous Delivery

### Definition

**Continuous Delivery** means software is kept in a deployable state and can be released through a controlled process.

A production approval may still be required.

~~~text
CI
 |
 v
Production-ready artifact
 |
 v
Approval
 |
 v
Production
~~~

### Analogy

A package is completely packed and ready at a delivery center.

It can ship, but someone may still approve the shipment.

---

## 5. Continuous Deployment

### Definition

**Continuous Deployment** automatically deploys changes that pass the required checks.

~~~text
Commit
 |
 v
Pipeline
 |
 v
Tests
 |
 v
Security
 |
 v
Automatic deployment
~~~

Continuous Delivery means **ready to deploy**.

Continuous Deployment means **automatically deployed**.

---

## 6. Pipeline

### Definition

A **pipeline** is an automated sequence of tasks that moves a change through defined stages.

Example:

~~~text
SOURCE
  |
BUILD
  |
TEST
  |
SECURITY
  |
PACKAGE
  |
RELEASE
  |
DEPLOY
  |
VERIFY
~~~

Each stage should have a clear purpose.

---

## 7. Build

A build converts source code into something executable or deployable.

Examples:

- compile Java;
- build a frontend bundle;
- install/package Python;
- build a Docker image.

Container example:

~~~text
Source
  |
  v
Dockerfile
  |
  v
Container image
~~~

---

## 8. Testing

Tests provide feedback before deployment.

### Unit tests

Test small pieces of code.

### Integration tests

Test components working together.

### End-to-end tests

Test a user/business workflow.

A mature pipeline may use:

~~~text
Fast unit tests
      |
      v
Build
      |
      v
Integration tests
      |
      v
Security
      |
      v
Deployment tests
~~~

---

## 9. Artifacts

### Definition

An **artifact** is an output produced by a pipeline.

Examples:

- compiled binary;
- package;
- test report;
- Docker image;
- deployment manifest.

### Analogy: packaged product

Source code is the recipe.

The artifact is the packaged product produced from that recipe.

---

## 10. Environments

Typical environments:

~~~text
Development
     |
     v
Staging
     |
     v
Production
~~~

They provide increasing levels of confidence and risk.

Production should not be the first place a change is tested.

---

## 11. Quality gates

### Definition

A **quality gate** is a condition that must be satisfied before the pipeline continues.

Examples:

- tests pass;
- coverage requirement met;
- vulnerability threshold acceptable;
- image builds;
- policy checks pass.

Example:

~~~text
Tests
  |
  +-- FAIL → STOP
  |
  v
Security
  |
  +-- FAIL → STOP
  |
  v
Deploy
~~~

A failed gate should stop unsafe promotion.

---

## 12. Secrets in CI/CD

Never hard-code credentials in source code.

Bad:

~~~text
AWS_PASSWORD=...
PROD_TOKEN=...
DOCKER_PASSWORD=...
~~~

Use:

- CI/CD secret stores;
- repository/environment secrets;
- cloud identity federation where supported;
- short-lived credentials.

### Analogy: safe deposit box

A password should not be taped to the production machine.

It belongs in a controlled credential system.

---

## 13. Security in the pipeline

A secure pipeline may include:

~~~text
Source
  |
SAST
  |
Dependencies
  |
Container
  |
Infrastructure
  |
Deployment
~~~

Checks can include:

- SAST;
- SCA;
- secret scanning;
- container scanning;
- IaC scanning;
- policy validation.

Security should be integrated rather than added only after deployment.

---

## 14. Deployment strategies

### Recreate

Stop the old version and start the new version.

Simple, but can cause downtime.

### Rolling

Gradually replace old instances.

Common with Kubernetes Deployments.

### Blue/Green

Two environments exist:

~~~text
Blue = current
Green = new
~~~

Traffic switches after validation.

### Canary

A small percentage receives the new version first.

~~~text
95% → v1
5%  → v2
~~~

Observe before increasing traffic.

---

## 15. Rollback

A good pipeline must answer:

> **What happens if deployment fails?**

Possible mechanisms:

- Kubernetes rollout undo;
- Helm rollback;
- previous image;
- previous infrastructure state;
- traffic switch back.

Rollback should be tested before an emergency.

---

## 16. Pipeline design principles

### Fast feedback

Run inexpensive checks early.

### Repeatability

The same source should produce predictable results.

### Traceability

Know which commit produced which artifact.

### Immutability

Prefer versioned artifacts instead of silently changing one artifact.

### Least privilege

Pipeline credentials should have only required permissions.

### Observability

Record logs, test results and deployment status.

---

## 17. Example pipeline

~~~text
Developer pushes commit
        |
        v
GitHub
        |
        v
CI
 ├── lint
 ├── test
 ├── build
 ├── scan
 └── package
        |
        v
Container Registry
        |
        v
Staging
        |
        v
Smoke test
        |
        v
Approval
        |
        v
Production
        |
        v
Health check
~~~

---

## 18. Hands-on lab

Create a pipeline that:

1. checks out code;
2. installs dependencies;
3. runs tests;
4. builds the application;
5. builds a Docker image;
6. scans it;
7. publishes a versioned image;
8. deploys to a test namespace;
9. waits for rollout;
10. runs a health check.

Start with CI only.

Then add deployment.

This makes failures easier to understand.

---

## 19. Troubleshooting CI/CD

### Pipeline never starts

Check:

- workflow trigger;
- branch;
- syntax;
- permissions.

### Build fails

Check:

- dependency versions;
- runtime version;
- lockfile;
- environment variables.

### Tests pass locally but fail in CI

Common causes:

- environment differences;
- missing dependency;
- time zone;
- hidden state;
- external service dependency.

### Deployment fails

Check:

- credentials;
- image;
- cluster access;
- namespace;
- manifests;
- rollout status.

---

## 20. Knowledge check

1. What is CI?
2. What is Continuous Delivery?
3. What is Continuous Deployment?
4. What is a pipeline?
5. What is an artifact?
6. Why use quality gates?
7. Why should secrets not be committed?
8. What is a rolling deployment?
9. What is canary deployment?
10. Why is rollback important?
11. What does traceability mean?
12. Why automate security checks?

### Answers

1. Frequent integration with automated validation.
2. Keeping software deployable through a controlled release process.
3. Automatically deploying validated changes.
4. Automated delivery stages.
5. Produced output such as an image or package.
6. To stop unsafe changes.
7. Credentials can be exposed and difficult to revoke safely.
8. Gradual replacement of old instances.
9. Releasing a small percentage first.
10. To recover safely from failed changes.
11. Knowing which source change produced an artifact/deployment.
12. To detect risks consistently and early.

---

## 21. Day 18 challenge

Design a pipeline for a containerized web application.

It must:

- test code;
- build an image;
- scan it;
- push a versioned image;
- deploy to staging;
- verify health;
- require approval before production;
- support rollback.

Draw the pipeline and explain every stage.

### FOMA takeaway

> **CI/CD is not just automation. It is a controlled system for turning source changes into trusted, traceable and repeatable releases.**

**Learn • Practice • Build • Troubleshoot • Advance**

https://foma.life
