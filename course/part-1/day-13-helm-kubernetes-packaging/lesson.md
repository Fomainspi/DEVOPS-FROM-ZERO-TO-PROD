# Day 13 — Helm & Kubernetes Packaging

> **FOMA · William Foma**  
> **DEVOPS FROM ZERO TO PRODUCTION**  
> Package, configure, release, upgrade and rollback Kubernetes applications with Helm.

---

## 1. Learning objectives

By the end of this lesson, you will be able to:

- explain why Helm exists;
- define Chart, Release, Values, Template and Repository;
- understand how Helm converts templates into Kubernetes manifests;
- create and customize a chart;
- install, upgrade and rollback releases;
- manage chart dependencies;
- use environment-specific values;
- troubleshoot Helm deployments.

---

# 2. Why Helm?

Imagine an application requires:

~~~text
Deployment
Service
ConfigMap
Secret
Ingress
ServiceAccount
HPA
~~~

Managing these files manually for one application is possible.

Managing them for 30 applications across development, staging and production becomes repetitive.

### Definition

**Helm is a package manager and release-management tool for Kubernetes.**

Helm packages Kubernetes resources into reusable **Charts** and manages installed instances called **Releases**.

### Analogy: Linux package manager

With a Linux package manager, you can install an application as a package instead of manually assembling every file.

Helm applies the same general idea to Kubernetes resources.

~~~text
Helm Chart
    |
    v
Rendered Kubernetes manifests
    |
    v
Kubernetes
    |
    v
Helm Release
~~~

Helm does not replace Kubernetes. Kubernetes still creates and operates the workloads.

---

# 3. The five concepts you must know

| Concept | Definition | Analogy |
|---|---|---|
| Chart | Reusable Kubernetes application package | Software package |
| Values | Configuration supplied to a chart | Settings |
| Template | Parameterized Kubernetes manifest | Blueprint |
| Release | Installed instance of a chart | Installed copy |
| Repository | Source of charts | App store |

The central Helm flow is:

~~~text
Chart + Values
      |
      v
Templates
      |
      v
Rendered YAML
      |
      v
Kubernetes API
      |
      v
Release
~~~

---

# 4. Chart

### Definition

A **Chart** is a directory/package containing the information required to deploy a Kubernetes application.

Create one:

~~~bash
helm create foma-app
~~~

Typical structure:

~~~text
foma-app/
├── Chart.yaml
├── values.yaml
├── charts/
├── templates/
│   ├── deployment.yaml
│   ├── service.yaml
│   └── _helpers.tpl
└── README.md
~~~

### Analogy: building blueprint

A blueprint is not the finished building.

It describes how to build the building.

A Helm Chart is similar: it describes how Kubernetes resources should be created.

---

# 5. Chart.yaml

### Definition

Chart.yaml contains chart metadata.

Example:

~~~yaml
apiVersion: v2
name: foma-app
description: FOMA Kubernetes application
type: application
version: 0.1.0
appVersion: "1.0.0"
~~~

Two versions may appear:

- **Chart version** — version of the packaging.
- **App version** — version of the application being packaged.

They can change independently.

---

# 6. values.yaml

### Definition

values.yaml contains default configuration values used by templates.

Example:

~~~yaml
replicaCount: 2

image:
  repository: nginx
  tag: "1.25"

service:
  type: ClusterIP
  port: 80
~~~

### Why?

The same chart can be used in multiple environments.

~~~text
One chart
   |
   +---- dev values
   +---- staging values
   +---- production values
~~~

### Analogy: restaurant order

The kitchen is the same.

The customer changes:

- quantity;
- size;
- toppings.

The kitchen does not need a completely different restaurant.

The chart is the kitchen. Values are the order.

---

# 7. Templates

### Definition

A **Helm template** is a Kubernetes manifest containing expressions that Helm evaluates.

Example:

~~~yaml
spec:
  replicas: {{ .Values.replicaCount }}
~~~

If the value is 3, Helm renders:

~~~yaml
spec:
  replicas: 3
~~~

Image example:

~~~yaml
image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
~~~

### Mental model

~~~text
Template
   +
Values
   |
   v
Helm rendering
   |
   v
Normal Kubernetes YAML
~~~

This is the key idea behind Helm.

---

# 8. Install and verify Helm

Check:

~~~bash
helm version
~~~

Add a repository:

~~~bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
~~~

Search:

~~~bash
helm search repo nginx
~~~

### Definition: repository

A Helm repository is a source from which Helm discovers and downloads charts.

### Analogy: app store

Repository = app store.

Chart = application package in the store.

---

# 9. Render before deployment

One of the best Helm habits is:

> **Render first. Deploy second.**

Run:

~~~bash
helm template foma-app ./foma-app
~~~

This shows the Kubernetes YAML Helm would generate.

### Why?

A template can contain errors.

Rendering allows you to inspect the result before sending it to Kubernetes.

### Analogy: test-printing a document

You preview a document before printing 500 copies.

Similarly, render a chart before deploying it to a cluster.

---

# 10. Validate with helm lint

Run:

~~~bash
helm lint ./foma-app
~~~

### Definition

helm lint checks a chart for common structural and template problems.

It is useful, but it is not a complete application test.

A strong pipeline can use:

~~~text
helm lint
    |
    v
helm template
    |
    v
Kubernetes validation
    |
    v
Application tests
~~~

---

# 11. Install a release

Install:

~~~bash
helm install foma-app ./foma-app \
  --namespace production \
  --create-namespace
~~~

Inspect:

~~~bash
helm list -n production
helm status foma-app -n production
kubectl get all -n production
~~~

### Definition: Release

A **Release** is an installed instance of a Chart.

One Chart can produce many Releases:

~~~text
Chart: foma-app

Release: foma-dev
Release: foma-staging
Release: foma-prod
~~~

### Analogy

The Chart is the software package.

The Release is the installed copy.

---

# 12. Override values

Use --set for simple changes:

~~~bash
helm install foma-app ./foma-app \
  --set replicaCount=3
~~~

Use a values file for repeatable environment configuration:

~~~bash
helm install foma-app ./foma-app \
  -f values-prod.yaml
~~~

A common layout:

~~~text
values.yaml
values-dev.yaml
values-staging.yaml
values-prod.yaml
~~~

This avoids copying the entire chart for each environment.

---

# 13. Upgrade

Suppose production currently uses two replicas.

Upgrade:

~~~bash
helm upgrade foma-app ./foma-app \
  -n production \
  --set replicaCount=3
~~~

Inspect:

~~~bash
helm status foma-app -n production
kubectl get deployment -n production
~~~

The release receives a new revision.

~~~text
Revision 1
    |
    v
Revision 2
    |
    v
Revision 3
~~~

Helm keeps release history so operators can inspect and recover from changes.

---

# 14. Rollback

If the latest revision is broken:

~~~bash
helm history foma-app -n production
~~~

Then:

~~~bash
helm rollback foma-app 1 -n production
~~~

Verify:

~~~bash
helm status foma-app -n production
~~~

### Analogy: version history

Think about Git.

If the newest change breaks the application, you can return to a known good version.

Helm provides a similar release-history concept.

---

# 15. Dependencies

Applications may depend on other services.

Example:

~~~text
Web application
     |
     +---- Redis
     |
     +---- PostgreSQL
~~~

Helm dependencies can be declared in Chart.yaml.

Example:

~~~yaml
dependencies:
  - name: redis
    version: "20.x.x"
    repository: "https://charts.bitnami.com/bitnami"
~~~

Update dependencies:

~~~bash
helm dependency update
~~~

### Analogy

Building a car requires many components.

The car manufacturer does not reinvent every component.

A chart can similarly depend on packaged components.

For production, choose and pin versions deliberately.

---

# 16. Helm troubleshooting

### Chart not found

~~~bash
helm repo list
helm repo update
helm search repo <keyword>
~~~

### Template error

~~~bash
helm lint ./foma-app
helm template foma-app ./foma-app --debug
~~~

Look for:

- wrong value names;
- missing values;
- invalid template syntax;
- YAML indentation problems.

### Release installed but application is broken

This is important:

> **Helm success does not mean application health.**

Inspect Kubernetes:

~~~bash
kubectl get pods -n production
kubectl describe pod <pod> -n production
kubectl logs <pod> -n production
kubectl get events -n production --sort-by=.lastTimestamp
~~~

Helm can successfully create a Deployment while its Pods still:

- fail to start;
- fail readiness;
- fail to pull an image;
- crash.

Always validate the resulting workload.

---

# 17. Useful commands

### Repository

~~~bash
helm repo list
helm repo update
helm search repo <keyword>
~~~

### Chart

~~~bash
helm create <chart>
helm lint <chart>
helm template <release> <chart>
helm show chart <chart>
helm show values <chart>
~~~

### Release

~~~bash
helm install <release> <chart>
helm list
helm status <release>
helm history <release>
helm upgrade <release> <chart>
helm rollback <release> <revision>
helm uninstall <release>
~~~

### Inspect deployed configuration

~~~bash
helm get values <release>
helm get manifest <release>
~~~

---

# 18. Hands-on project

Create a reusable FOMA application chart.

### Task 1

~~~bash
helm create foma-app
~~~

### Task 2

Make these configurable:

- image repository;
- image tag;
- replica count;
- Service type;
- Service port;
- resource requests and limits.

### Task 3

Validate:

~~~bash
helm lint ./foma-app
helm template foma-app ./foma-app
~~~

### Task 4

Install:

~~~bash
helm install foma-app ./foma-app \
  -n production \
  --create-namespace
~~~

### Task 5

Upgrade from 2 to 3 replicas.

### Task 6

Use an intentionally invalid image tag.

Observe the failure.

### Task 7

Troubleshoot using Helm and kubectl.

### Task 8

Rollback to the previous healthy release.

### Task 9

Create dev, staging and production values files.

---

# 19. Production best practices

- Keep charts in Git.
- Render important changes before deployment.
- Use helm lint in CI.
- Prefer versioned values files.
- Pin important chart/application versions.
- Keep real credentials out of Git.
- Understand every resource generated by a chart.
- Test upgrades and rollbacks.
- Separate chart packaging from application health validation.
- Avoid unnecessary template complexity.

---

# 20. Knowledge check

1. What is Helm?
2. What is a Chart?
3. What is a Release?
4. What is values.yaml?
5. What is a Template?
6. What does helm template do?
7. What does helm lint do?
8. What is a Helm repository?
9. How do you install a release?
10. How do you upgrade a release?
11. How do you rollback?
12. Where are dependencies declared?
13. Why use environment-specific values?
14. Does Helm replace Kubernetes?
15. Can Helm report success while an application is unhealthy?

### Answers

1. A Kubernetes packaging and release-management tool.
2. A reusable Kubernetes application package.
3. An installed instance of a chart.
4. Default/configurable chart values.
5. A parameterized Kubernetes manifest.
6. Renders templates into Kubernetes YAML.
7. Checks for common chart problems.
8. A source of Helm charts.
9. helm install.
10. helm upgrade.
11. helm rollback.
12. Chart.yaml.
13. To reuse one chart with different environment settings.
14. No.
15. Yes.

---

# 21. Day 13 challenge

Create one reusable chart for the same application in three environments.

Demonstrate:

1. chart creation;
2. values customization;
3. linting;
4. rendering;
5. installation;
6. upgrade;
7. failed deployment;
8. troubleshooting;
9. rollback;
10. release history.

### FOMA takeaway

> **Helm makes Kubernetes applications reusable and configurable, but Helm is not magic: you still need to understand the Kubernetes resources that the chart creates.**

**Learn • Practice • Build • Troubleshoot • Advance**

https://foma.life
