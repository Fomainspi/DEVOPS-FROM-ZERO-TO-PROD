# Day 22 — Production DevOps Capstone

> **FOMA · William Foma**  
> **DEVOPS FROM ZERO TO PRODUCTION**  
> Bring the entire DevOps toolchain together in one production-oriented project.

---

## 1. Capstone objective

This is the integration day.

You will combine:

~~~text
Linux
  ↓
Git
  ↓
GitHub
  ↓
Python / Application
  ↓
Docker
  ↓
CI/CD
  ↓
Terraform
  ↓
AWS
  ↓
Kubernetes
  ↓
Helm
  ↓
Security
  ↓
Observability
~~~

The goal is not command memorization.

The goal is demonstrating an engineering workflow from source code to production.

---

## 2. The scenario

Build and operate a small API called:

**FOMA Production API**

Requirements:

- source code in Git;
- automated tests;
- container image;
- image security scanning;
- infrastructure as code;
- Kubernetes deployment;
- Helm packaging;
- ConfigMap and Secret;
- RBAC;
- health checks;
- CI/CD;
- production verification;
- rollback;
- documentation.

---

## 3. Target architecture

~~~text
                    INTERNET
                       |
                       v
                Load Balancer / Ingress
                       |
                       v
                    Service
                       |
              +--------+--------+
              |        |        |
             Pod      Pod      Pod
              |
       +------+------+------+
       |      |      |      |
    Config  Secret  Image  Logs
       |
       v
    Application
       |
       +------ Database
       |
       +------ Object storage
~~~

Delivery:

~~~text
Developer
   |
   v
GitHub
   |
   v
CI
   |
   +-- Test
   +-- Build
   +-- Scan
   +-- Package
   |
   v
Container Registry
   |
   v
Kubernetes
   |
   +-- Helm
   +-- RBAC
   +-- Service
   +-- Ingress
   +-- Config
   +-- Storage
   |
   v
Monitoring
~~~

---

## 4. Project structure

~~~text
foma-production-api/
├── app/
│   ├── app.py
│   └── requirements.txt
├── tests/
│   └── test_health.py
├── Dockerfile
├── .dockerignore
├── .gitignore
├── helm/
│   └── foma-api/
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── k8s/
├── .github/
│   └── workflows/
│       └── ci-cd.yml
└── README.md
~~~

---

## 5. Application

Create:

~~~text
GET /health
~~~

Expected response:

~~~json
{
  "status": "ok"
}
~~~

The health endpoint becomes an automated signal that the application is alive.

---

## 6. Testing

Create a test for:

~~~text
GET /health → HTTP 200
~~~

Run:

~~~bash
pytest
~~~

### Principle

> Do not deploy an application that you cannot test automatically.

---

## 7. Docker

Example:

~~~dockerfile
FROM python:3.12-slim

WORKDIR /app

COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app/ .

EXPOSE 8000

CMD ["python", "app.py"]
~~~

Build:

~~~bash
docker build -t foma-api:dev .
~~~

Run:

~~~bash
docker run --rm -p 8000:8000 foma-api:dev
~~~

Test:

~~~bash
curl http://localhost:8000/health
~~~

---

## 8. Container security

Production image practices:

- trusted small base image;
- pinned dependencies;
- non-root user where practical;
- no secrets in image;
- dependency scanning;
- image scanning;
- no unnecessary packages.

### Analogy

Do not ship an entire warehouse when the customer needs one toolbox.

Smaller images reduce unnecessary software and attack surface.

---

## 9. Terraform

Terraform manages infrastructure.

Possible responsibilities:

~~~text
AWS
 |
 +-- VPC
 +-- subnets
 +-- IAM
 +-- ECR
 +-- EKS or compute
 +-- supporting services
~~~

Keep this boundary clear:

~~~text
Terraform
   |
   v
Infrastructure

Helm / Kubernetes
   |
   v
Application deployment
~~~

---

## 10. Helm

Package the application:

~~~text
helm/foma-api/
├── Chart.yaml
├── values.yaml
└── templates/
    ├── deployment.yaml
    ├── service.yaml
    ├── ingress.yaml
    ├── configmap.yaml
    ├── secret.yaml
    └── serviceaccount.yaml
~~~

Values should control:

- image repository;
- image tag;
- replicas;
- Service;
- resources;
- environment settings.

---

## 11. Kubernetes deployment

Target:

~~~yaml
replicas: 3
~~~

Include:

- readiness probe;
- liveness probe where appropriate;
- resource requests;
- resource limits;
- Service;
- ConfigMap;
- Secret;
- ServiceAccount.

Example readiness:

~~~yaml
readinessProbe:
  httpGet:
    path: /health
    port: 8000
  initialDelaySeconds: 5
  periodSeconds: 10
~~~

---

## 12. RBAC

Create a dedicated ServiceAccount.

Do not use the default identity for everything.

Grant only the permissions genuinely required.

If the application does not need Kubernetes API access:

> **Do not grant it Kubernetes API permissions.**

Security includes knowing when not to grant access.

---

## 13. Ingress

Expose the application:

~~~text
api.foma.local
      |
      v
Ingress
      |
      v
foma-api Service
      |
      v
3 Pods
~~~

Production requirements include:

- real DNS;
- TLS;
- maintained Ingress/Gateway implementation;
- certificate management.

---

## 14. Configuration

Use ConfigMap for:

- environment;
- log level;
- non-sensitive settings.

Use Secret for:

- credentials;
- tokens;
- certificates;
- sensitive configuration.

Never commit production credentials to Git.

---

## 15. CI/CD pipeline

~~~text
Push / Pull Request
       |
       v
Lint
       |
       v
Test
       |
       v
Build
       |
       v
Security scan
       |
       v
Push versioned image
       |
       v
Deploy staging
       |
       v
Smoke test
       |
       v
Production approval
       |
       v
Deploy production
       |
       v
Verify
~~~

Each stage needs a clear failure condition.

---

## 16. Image versioning

Do not depend only on latest.

Prefer immutable identifiers such as:

~~~text
foma-api:1.0.0
foma-api:<git-sha>
~~~

### Why?

If latest changes, it may become difficult to identify exactly what is running.

A Git SHA gives traceability back to source.

---

## 17. Deployment strategy

Start with a rolling deployment.

For higher-risk releases, consider:

- canary;
- blue/green;
- progressive delivery.

Before production:

> **Know how you will roll back.**

---

## 18. Observability

Monitor:

### Application

- health;
- latency;
- error rate.

### Kubernetes

- Pod status;
- restarts;
- CPU;
- memory;
- rollout status.

### Infrastructure

- node health;
- network;
- storage;
- cloud metrics.

### Logs

Centralize logs when required by the platform.

A production system without observability is difficult to operate safely.

---

## 19. Failure scenarios

The capstone must intentionally test failures.

### Failure 1 — Bad image

Deploy an invalid image tag.

Use:

~~~bash
kubectl describe pod <pod>
kubectl get events
~~~

### Failure 2 — Bad Service selector

Break the selector.

Observe:

~~~text
Service
   |
   X
No endpoints
~~~

### Failure 3 — Failed readiness

Break the health endpoint.

Observe how traffic changes.

### Failure 4 — Pipeline test failure

Introduce a failing test.

The pipeline should stop before deployment.

### Failure 5 — Rollback

Deploy a deliberately broken version.

Recover using Kubernetes rollout undo or Helm rollback.

---

## 20. Security acceptance criteria

The capstone is not complete until:

- no production secrets are committed;
- least-privilege RBAC is used;
- containers run without unnecessary privileges;
- image is scanned;
- Terraform state is protected;
- CI permissions are minimized;
- production deployment is controlled;
- TLS is used for external traffic.

---

## 21. Infrastructure acceptance criteria

The platform should have:

- repeatable Terraform;
- documented variables;
- controlled state;
- network design;
- security boundaries;
- cost awareness;
- documented cleanup.

---

## 22. CI/CD acceptance criteria

The pipeline must:

- run automatically;
- fail on broken tests;
- build a versioned artifact;
- perform security checks;
- deploy after required gates;
- report rollout status;
- support rollback.

---

## 23. Kubernetes acceptance criteria

The application should have:

- Deployment;
- multiple replicas;
- Service;
- readiness probe;
- resource requests and limits;
- ConfigMap;
- Secret;
- ServiceAccount;
- appropriate RBAC;
- Ingress/TLS where required.

---

## 24. Production troubleshooting runbook

When production fails:

### Step 1 — Confirm impact

~~~bash
kubectl get pods -n production
~~~

### Step 2 — Check rollout

~~~bash
kubectl rollout status deployment/foma-api -n production
~~~

### Step 3 — Check events

~~~bash
kubectl get events -n production --sort-by=.lastTimestamp
~~~

### Step 4 — Inspect Pods

~~~bash
kubectl describe pod <pod> -n production
~~~

### Step 5 — Logs

~~~bash
kubectl logs <pod> -n production
~~~

### Step 6 — Service

~~~bash
kubectl get endpoints foma-api -n production
~~~

### Step 7 — Roll back if required

~~~bash
kubectl rollout undo deployment/foma-api -n production
~~~

Restore service first; perform deeper root-cause analysis after stabilization when appropriate.

---

## 25. Production readiness checklist

### Source control

- [ ] Git history is clean
- [ ] branch protection
- [ ] code review

### Application

- [ ] automated tests
- [ ] health endpoint
- [ ] externalized configuration

### Container

- [ ] versioned image
- [ ] image scan
- [ ] no secrets in image
- [ ] unnecessary packages removed

### Kubernetes

- [ ] Deployment
- [ ] Service
- [ ] probes
- [ ] resources
- [ ] ConfigMap
- [ ] Secret
- [ ] RBAC
- [ ] Ingress/TLS

### Terraform

- [ ] infrastructure as code
- [ ] reviewed plan
- [ ] protected state
- [ ] externalized credentials

### CI/CD

- [ ] tests
- [ ] build
- [ ] security
- [ ] image
- [ ] staging
- [ ] approval
- [ ] production
- [ ] rollback

### Operations

- [ ] logs
- [ ] metrics
- [ ] alerts
- [ ] runbook
- [ ] backup/recovery
- [ ] cost controls

---

## 26. Final capstone challenge

### Phase 1 — Application

Create the API and tests.

### Phase 2 — Container

Build and run Docker image.

### Phase 3 — Source control

Push to GitHub.

### Phase 4 — CI

Automate linting, tests and image building.

### Phase 5 — Infrastructure

Use Terraform for platform infrastructure.

### Phase 6 — Kubernetes

Deploy with Helm.

### Phase 7 — Security

Implement ServiceAccount and least-privilege RBAC.

### Phase 8 — Networking

Expose through Service and Ingress/TLS.

### Phase 9 — Observability

Add health checks, logs and monitoring.

### Phase 10 — Failure testing

Break the application deliberately and recover it.

### Phase 11 — Documentation

Document:

- architecture;
- deployment;
- troubleshooting;
- rollback;
- security;
- cleanup.

---

## 27. Final knowledge check

1. Why separate application and infrastructure deployment?
2. Why use immutable image tags?
3. Why are readiness probes important?
4. Why use dedicated ServiceAccounts?
5. Why keep production secrets out of Git?
6. Why use Terraform?
7. Why use Helm?
8. Why scan container images?
9. Why test rollback?
10. What does a production runbook provide?
11. What should happen when CI tests fail?
12. What makes a system production-ready?

### Answers

1. They have different lifecycles and responsibilities.
2. To make deployments traceable and reproducible.
3. To prevent traffic reaching an application that is not ready.
4. To support identity and least privilege.
5. Credentials can be exposed and difficult to revoke.
6. Repeatable infrastructure management.
7. Reusable Kubernetes application packaging.
8. To detect known security risks.
9. Recovery must be predictable during incidents.
10. A repeatable response procedure.
11. The pipeline should stop before unsafe promotion.
12. Reliability, security, observability, repeatability and recoverability.

---

## 28. What you should know by now.

~~~text
Developer changes code
        |
        v
Git records change
        |
        v
CI tests it
        |
        v
Docker packages it
        |
        v
Security checks it
        |
        v
Registry stores it
        |
        v
Terraform manages infrastructure
        |
        v
Helm packages Kubernetes deployment
        |
        v
Kubernetes runs it
        |
        v
Ingress exposes it
        |
        v
RBAC protects identities
        |
        v
Monitoring observes it
        |
        v
Rollback recovers it
~~~

That is the DevOps engineering lifecycle.

### FOMA final takeaway

> **DevOps is not a collection of tools. It is the engineering discipline of building, delivering, operating, securing and continuously improving software through automation and feedback.**

# PART 1 COMPLETE — DEVOPS & LINUX FOUNDATION

**Learn • Practice • Build • Troubleshoot • Automate • Operate**

**Foundation of Mastering Automation (FOMA)**  
William Foma — DevOps Trainer  
https://foma.life
