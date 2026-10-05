# Day 11 — Helm & Kubernetes Packaging

> **FOMA — DEVOPS FROM ZERO TO PRODUCTION**

## 1. Mission

Raw Kubernetes manifests are powerful, but real applications often have many resources and environment-specific settings. **Helm packages Kubernetes resources into reusable Charts and manages deployments as Releases.**

### Objectives
- Understand Helm and why it is used.
- Install and verify the Helm CLI.
- Create and inspect Charts.
- Use values.yaml and templates.
- Install, upgrade, rollback, and uninstall Releases.
- Work with repositories.
- Validate and troubleshoot Charts.
- Apply production packaging practices.

## 2. Helm mental model

~~~text
Chart + values
      |
      v
  Templates
      |
      v
Kubernetes manifests
      |
      v
   Release
~~~

A **Chart** is the package. **Templates** generate Kubernetes manifests. **Values** provide configuration. A **Release** is an installed instance of a Chart.

### Typical Chart

~~~text
foma-app/
├── Chart.yaml
├── values.yaml
├── templates/
│   ├── deployment.yaml
│   ├── service.yaml
│   └── _helpers.tpl
└── charts/
~~~

## 3. Install and verify Helm

After installing Helm using the official method for your OS:

~~~bash
helm version
helm help
helm repo list
~~~

Add a repository:

~~~bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm search repo nginx
~~~

## 4. Create a Chart

~~~bash
helm create foma-app
cd foma-app
tree
~~~

Key files:
- Chart.yaml — metadata.
- values.yaml — default configuration.
- templates/ — Kubernetes templates.
- charts/ — dependencies.

## 5. Deploy with Helm

~~~bash
helm install foma-app ./foma-app
helm list
helm status foma-app
kubectl get all -l app.kubernetes.io/instance=foma-app
~~~

From a repository:

~~~bash
helm install nginx bitnami/nginx
~~~

A release gives you a named deployment lifecycle that Helm tracks.

## 6. Values and environments

Example values:

~~~yaml
replicaCount: 2

image:
  repository: nginx
  tag: "1.27"

service:
  type: ClusterIP
  port: 80
~~~

Use an environment file:

~~~bash
helm install foma-app ./foma-app -f values-prod.yaml
~~~

Override one value:

~~~bash
helm upgrade foma-app ./foma-app --set replicaCount=3
~~~

A strong pattern is values.yaml for defaults plus explicit environment files for dev, test, and production.

Keep sensitive production data out of ordinary values files unless your storage and encryption model is appropriate.

## 7. Templates

Render before installing:

~~~bash
helm template foma-app ./foma-app
helm template foma-app ./foma-app -f values-prod.yaml
~~~

Validate:

~~~bash
helm lint ./foma-app
helm template foma-app ./foma-app --debug
helm install foma-app ./foma-app --dry-run --debug
~~~

Templates let one Chart generate environment-specific manifests.

## 8. Release management

~~~bash
helm upgrade foma-app ./foma-app
helm status foma-app
helm history foma-app
helm get values foma-app
helm get manifest foma-app
~~~

Rollback:

~~~bash
helm rollback foma-app 1
helm status foma-app
~~~

Uninstall:

~~~bash
helm uninstall foma-app
~~~

**Mental model:** Kubernetes manages desired state in the cluster; Helm manages the packaged release lifecycle that produces that desired state.

## 9. Repositories

~~~bash
helm repo list
helm repo add <name> <url>
helm repo update
helm search repo <keyword>
helm show chart <repo/chart>
helm show values <repo/chart>
helm pull <repo/chart>
~~~

For production, evaluate chart ownership, source, version, update history, permissions, and security before installing third-party charts.

## 10. Troubleshooting

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

### Release installed but Pods fail

Helm can succeed while Kubernetes fails. Continue with Kubernetes diagnostics:

~~~bash
helm status foma-app
kubectl get pods
kubectl describe pod <pod>
kubectl logs <pod>
kubectl get events --sort-by=.lastTimestamp
~~~

### Upgrade behaves unexpectedly
~~~bash
helm get values foma-app
helm history foma-app
helm get manifest foma-app
~~~

## 11. Hands-on practice

1. Install Helm and verify it.
2. Add and update a chart repository.
3. Create foma-app.
4. Inspect Chart.yaml, values.yaml, and templates.
5. Set replicas and an image tag.
6. Render with helm template.
7. Run helm lint.
8. Install the Chart.
9. Verify Kubernetes resources.
10. Upgrade a value.
11. Inspect release history.
12. Roll back.
13. Uninstall.
14. Deploy a real chart such as nginx after reviewing its values.

### Knowledge check
1. What is a Helm Chart?
2. What is a Release?
3. What is values.yaml for?
4. What does helm template do?
5. Why use helm lint?
6. What is helm upgrade?
7. How do you roll back?
8. How do you inspect release history?
9. Why should production values be controlled carefully?
10. What do you check when Helm installs successfully but Pods fail?

## Helm cheat sheet

~~~bash
helm version
helm repo add <name> <url>
helm repo update
helm search repo <term>
helm create <chart>
helm lint <chart>
helm template <release> <chart>
helm install <release> <chart>
helm list
helm status <release>
helm upgrade <release> <chart>
helm history <release>
helm rollback <release> <revision>
helm uninstall <release>
~~~

## Golden rules
- Pin and review chart versions.
- Keep configuration in values rather than duplicating templates.
- Validate with helm lint and helm template.
- Review rendered manifests before production deployment.
- Keep environment configuration explicit.
- Protect sensitive values.
- Test upgrades and rollbacks.
- Treat third-party charts as software dependencies.

> **FOMA principle:** Helm is not magic. It is a packaging and release-management layer. Understand the Kubernetes manifests it generates.

**Next:** Day 12 — Kubernetes Applications

**William Foma | Foundation of Mastering Automation | https://foma.life**
