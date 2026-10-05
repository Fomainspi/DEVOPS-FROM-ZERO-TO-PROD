# Day 13 — Helm & Kubernetes Packaging

> FOMA · William Foma · Simplify, deploy and manage applications with Helm

## 1. What is Helm?

Helm is a package manager for Kubernetes. A **Chart** packages templates and metadata; a **Release** is an installed instance of that chart.

Mental model:

**Chart + Values → Templates → Kubernetes manifests → Release**

Helm does not replace Kubernetes. It helps package and manage Kubernetes resources.

## 2. Install and verify

~~~bash
helm version
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm search repo nginx
~~~

## 3. Chart structure

~~~bash
helm create foma-app
cd foma-app
tree .
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

**Chart.yaml** contains metadata.  
**values.yaml** contains defaults.  
**templates/** contains parameterized Kubernetes manifests.

## 4. Values and templates

~~~yaml
replicaCount: 2

image:
  repository: nginx
  tag: "1.25"

service:
  type: ClusterIP
  port: 80
~~~

Template example:

~~~yaml
spec:
  replicas: {{ .Values.replicaCount }}
  containers:
    - name: web
      image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
~~~

The same chart can serve development, staging and production through different values files.

## 5. Validate before deployment

~~~bash
helm lint ./foma-app
helm template foma-app ./foma-app
helm install foma-app ./foma-app --dry-run --debug
~~~

Rendering first makes the generated Kubernetes manifests visible.

## 6. Install and manage a release

~~~bash
helm install foma-app ./foma-app -n production --create-namespace
helm list -n production
helm status foma-app -n production
kubectl get all -n production
~~~

## 7. Upgrade

~~~bash
helm upgrade foma-app ./foma-app -n production --set replicaCount=3
helm status foma-app -n production
kubectl rollout status deployment/foma-app -n production
~~~

For repeatability, prefer a versioned values file:

~~~bash
helm upgrade foma-app ./foma-app -n production -f values-prod.yaml
~~~

## 8. Rollback

~~~bash
helm history foma-app -n production
helm rollback foma-app 1 -n production
helm status foma-app -n production
~~~

Lifecycle:

**Package → Validate → Install → Observe → Upgrade → Rollback if required**

## 9. Repositories and dependencies

~~~bash
helm repo list
helm repo update
helm search repo redis
helm show chart bitnami/redis
~~~

Declare dependencies in Chart.yaml:

~~~yaml
dependencies:
  - name: redis
    version: "20.x.x"
    repository: "https://charts.bitnami.com/bitnami"
~~~

Then:

~~~bash
helm dependency update
~~~

Pin production versions intentionally.

## 10. Environment strategy

A common pattern:

~~~text
values.yaml
values-dev.yaml
values-staging.yaml
values-prod.yaml
~~~

Example production values:

~~~yaml
replicaCount: 5
resources:
  requests:
    cpu: 200m
    memory: 256Mi
~~~

## 11. Troubleshooting

Chart not found:
~~~bash
helm repo list
helm repo update
helm search repo <keyword>
~~~

Template failure:
~~~bash
helm lint ./foma-app
helm template foma-app ./foma-app --debug
~~~

Release failure:
~~~bash
helm status foma-app -n production
helm history foma-app -n production
kubectl get events -n production --sort-by=.lastTimestamp
~~~

Inspect what was actually deployed:

~~~bash
helm get values foma-app -n production
helm get manifest foma-app -n production
~~~

## 12. Hands-on project

Create a reusable foma-app chart.

1. Create the chart.
2. Parameterize image and replica count.
3. Parameterize Service type and port.
4. Add resources.
5. Lint and render.
6. Install into production.
7. Upgrade from 2 to 3 replicas.
8. Create staging values.
9. Roll back a release.
10. Document the chart.

## Knowledge check

1. What is a Chart?
2. What is a Release?
3. Why use values.yaml?
4. Why use helm template?
5. What does helm lint provide?
6. How do you upgrade?
7. How do you rollback?
8. Where are dependencies declared?
9. Why pin production chart versions?
10. Chart versus Release?

**Answers:** Chart = package; Release = installed instance; values.yaml = configurable defaults; helm template = render manifests; helm lint = chart validation; helm upgrade = upgrade; helm rollback = rollback; dependencies belong in Chart.yaml; pinned versions improve reproducibility; a chart is the package and a release is its deployed instance.

## FOMA takeaway

**Helm turns repetitive Kubernetes manifests into reusable, configurable and versioned application packages.**

Learn • Practice • Build • Advance  
https://foma.life
