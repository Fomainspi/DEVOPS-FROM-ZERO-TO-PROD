# Day 12 — Kubernetes Applications

> **FOMA · William Foma**  
> **DEVOPS FROM ZERO TO PRODUCTION**  
> Deploy, configure, expose, scale and safely update real-world applications on Kubernetes.

---

## 1. Learning objectives

By the end of this lesson, you should be able to:

- explain what a Kubernetes application is;
- understand Pods, Deployments, ReplicaSets and StatefulSets;
- explain why Services are needed;
- use ConfigMaps and Secrets correctly;
- understand PV, PVC and StorageClass;
- scale an application;
- perform rolling updates and rollbacks;
- troubleshoot common application failures;
- separate application code, configuration, credentials and persistent data.

---

# 2. What is a Kubernetes application?

### Definition

A **Kubernetes application** is a group of Kubernetes resources that work together to run and operate an application.

A web application is usually more than a Pod:

~~~text
User
  |
  v
Ingress / LoadBalancer
  |
  v
Service
  |
  +--------+--------+
  |        |        |
 Pod      Pod      Pod
  |
  +---- ConfigMap
  +---- Secret
  +---- Persistent storage
~~~

### Analogy: a restaurant

Think of an application as a restaurant:

- **Deployment** = manager deciding how many workers are needed.
- **ReplicaSet** = supervisor making sure the required number of workers exists.
- **Pods** = workers doing the actual work.
- **Service** = reception desk giving customers a stable contact point.
- **ConfigMap** = operating instructions.
- **Secret** = private keys/passwords.
- **Persistent storage** = the storage room containing important inventory.
- **Ingress** = the front entrance directing visitors.

The purpose of this separation is to give each Kubernetes object one clear responsibility.

---

# 3. Desired state and actual state

### Definition

Kubernetes is a **desired-state system**.

You declare what you want, and Kubernetes continuously works to make the cluster match that declaration.

Example:

~~~text
Desired state:
3 web Pods

Actual state:
2 web Pods
~~~

Kubernetes detects the difference and attempts to create another Pod.

### Analogy: thermostat

A thermostat is configured to keep a room at 24°C.

It repeatedly compares:

~~~text
Desired: 24°C
Actual: 21°C
       |
       v
Turn heating on
~~~

Kubernetes performs a similar reconciliation process.

This is one of the most important ideas in Kubernetes.

---

# 4. Pods

### Definition

A **Pod** is the smallest deployable unit in Kubernetes.

A Pod normally contains one main application container, although multiple tightly coupled containers can share a Pod.

Check Pods:

~~~bash
kubectl get pods
~~~

A Pod should normally be considered **replaceable**.

It can disappear because of:

- application failure;
- node failure;
- scaling;
- deployment updates;
- scheduling;
- maintenance.

### Analogy: temporary employee

Imagine a company needs three workers.

If one worker leaves, the company should not stop operating. Another worker should be assigned.

A Pod is similar: it performs the work, but Kubernetes controllers are responsible for maintaining the desired number of workers.

---

# 5. Deployment

### Definition

A **Deployment** manages the desired state and rollout of a stateless application.

Example:

~~~yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: foma-web
spec:
  replicas: 3
  selector:
    matchLabels:
      app: foma-web
  template:
    metadata:
      labels:
        app: foma-web
    spec:
      containers:
        - name: web
          image: nginx:1.25
          ports:
            - containerPort: 80
~~~

Apply it:

~~~bash
kubectl apply -f deployment.yaml
~~~

Inspect it:

~~~bash
kubectl get deployment
kubectl get replicasets
kubectl get pods
~~~

### What happens?

~~~text
Deployment
    |
    v
ReplicaSet
    |
    +---- Pod
    +---- Pod
    +---- Pod
~~~

The Deployment manages the ReplicaSet. The ReplicaSet maintains the desired number of Pods.

### Analogy: company manager

The Deployment is the manager saying:

> "We need three workers running version 1.25."

The ReplicaSet is the supervisor making sure three workers exist.

---

# 6. ReplicaSet

### Definition

A **ReplicaSet** maintains a specified number of matching Pods.

If the desired number is:

~~~yaml
replicas: 3
~~~

the ReplicaSet continuously tries to maintain three matching Pods.

Check:

~~~bash
kubectl get rs
~~~

### Why not create ReplicaSets directly?

Because a Deployment gives you additional application lifecycle features:

- rolling updates;
- revision history;
- rollback;
- controlled replacement of Pods.

### Analogy

The ReplicaSet is the staff counter:

> "We need 3 workers. I can only see 2. I need another one."

The Deployment decides which version of the application the staff should be running.

---

# 7. StatefulSet

### Definition

A **StatefulSet** manages workloads that require stable identity and/or stable storage relationships.

Typical examples:

- databases;
- clustered data stores;
- message systems;
- other stateful workloads.

A StatefulSet can create predictable Pod identities:

~~~text
database-0
database-1
database-2
~~~

A normal stateless Deployment is more concerned with interchangeable replicas.

### Analogy: numbered hotel rooms

A stateless web worker is like a temporary employee: any available employee can answer the next request.

A stateful database is more like a numbered hotel room:

> Room 101 is still Room 101.

The identity and relationship with storage can matter.

### Rule

Do not use StatefulSet simply because an application is "important."

Use it when stable identity and/or stateful storage behavior is actually required.

---

# 8. Services

## The problem

Pod IP addresses can change.

For example:

~~~text
web Pod
10.244.1.10
~~~

The Pod is replaced:

~~~text
new web Pod
10.244.1.22
~~~

If clients connect directly to Pod IPs, the application becomes difficult to operate.

### Definition

A **Service** provides a stable network endpoint for a group of Pods.

Example:

~~~yaml
apiVersion: v1
kind: Service
metadata:
  name: foma-web
spec:
  selector:
    app: foma-web
  ports:
    - port: 80
      targetPort: 80
  type: ClusterIP
~~~

### Important relationship

The Service uses its selector to find Pods.

~~~text
Service selector:
app=foma-web
       |
       v
Pod labels:
app=foma-web
~~~

Check:

~~~bash
kubectl get svc
kubectl describe svc foma-web
kubectl get endpoints foma-web
~~~

### Analogy: company telephone number

Employees may change desks.

Customers should not need a new phone number every time an employee changes.

The Service is the stable company number. Kubernetes directs traffic to the appropriate Pods.

---

# 9. Service types

| Type | Main purpose | Analogy |
|---|---|---|
| ClusterIP | Internal cluster access | Internal phone extension |
| NodePort | Expose through a node port | Side entrance |
| LoadBalancer | External load-balancer integration | Public reception |

ClusterIP is the default Service type.

For many internal application-to-application connections:

~~~text
Frontend
   |
   v
API Service
   |
   v
API Pods
~~~

---

# 10. ConfigMaps

### Definition

A **ConfigMap** stores non-sensitive configuration separately from the application image.

Examples:

- environment;
- log level;
- feature flags;
- non-sensitive URLs;
- application settings.

Example:

~~~yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: foma-config
data:
  APP_ENV: production
  LOG_LEVEL: info
~~~

### Why separate configuration?

Suppose the same application image is used in:

~~~text
Development
Staging
Production
~~~

The application code may be identical, but configuration differs.

You should not need to rebuild the image every time the API URL changes.

### Analogy: machine instructions

Imagine sending the same machine to three factories.

The machine is the same.

The operating instructions can be different.

The instructions are configuration; the machine is the application.

---

# 11. Secrets

### Definition

A **Secret** is a Kubernetes object intended for sensitive data such as:

- passwords;
- API tokens;
- credentials;
- certificates;
- private keys.

Example:

~~~yaml
apiVersion: v1
kind: Secret
metadata:
  name: foma-secret
type: Opaque
stringData:
  DB_PASSWORD: change-me
~~~

### Critical security lesson

**Base64 is not encryption.**

For example:

~~~text
password
   |
   v
Base64 encoding
   |
   v
cGFzc3dvcmQ=
~~~

The value can be decoded.

Production controls should include:

- RBAC;
- encryption at rest;
- restricted access;
- credential rotation;
- external secret management when appropriate.

### Analogy: key cabinet

A ConfigMap is like an office notice containing normal instructions.

A Secret is like the key to the office.

Both are configuration, but the Secret needs much tighter control.

---

# 12. Persistent storage

### Definition

A Pod is replaceable, but application data may need to survive Pod replacement.

The common Kubernetes storage relationship is:

~~~text
Pod
 |
 v
PVC
 |
 v
PV
 |
 v
StorageClass / storage backend
~~~

### PV — PersistentVolume

A **PersistentVolume** represents storage available to the cluster.

### PVC — PersistentVolumeClaim

A **PersistentVolumeClaim** is a workload's request for storage.

### StorageClass

A **StorageClass** describes a class of storage and how storage can be dynamically provisioned.

### Analogy: warehouse

- PV = storage unit.
- PVC = rental request.
- StorageClass = storage catalog and provisioning rules.
- Pod = customer using the storage.

Example PVC:

~~~yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: foma-data
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
~~~

For production, prefer appropriate dynamic provisioning instead of depending on hostPath.

---

# 13. Scaling

### Manual scaling

~~~bash
kubectl scale deployment foma-web --replicas=5
~~~

Verify:

~~~bash
kubectl get deployment
kubectl get pods -l app=foma-web
~~~

### Horizontal Pod Autoscaler

The **HPA** automatically adjusts replica count based on configured metrics.

~~~text
Low demand
   |
   v
2 Pods

High demand
   |
   v
5 Pods
~~~

Example:

~~~bash
kubectl autoscale deployment foma-web --cpu-percent=70 --min=2 --max=10
kubectl get hpa
~~~

### Analogy: supermarket checkout

Two checkout counters may be enough at 9 AM.

At lunchtime, the store opens more counters.

HPA makes a similar decision for application replicas.

---

# 14. Rolling updates

A **rolling update** gradually replaces old Pods with new Pods.

Example:

~~~text
Version 1
v1  v1  v1

        update

v1  v1  v2

        update

v1  v2  v2

        complete

v2  v2  v2
~~~

Change an image:

~~~bash
kubectl set image deployment/foma-web web=nginx:1.26
~~~

Watch:

~~~bash
kubectl rollout status deployment/foma-web
~~~

### Why rolling updates?

They can reduce downtime because old and new replicas can overlap during the transition.

Readiness probes are important because a new Pod should not receive traffic until the application is ready.

### Analogy: changing a team without closing the business

A company has three workers.

Instead of firing all three and hiring three replacements at once, it replaces them gradually.

The business continues operating while the team changes.

---

# 15. Rollback

Suppose version 2 has a serious problem.

Check history:

~~~bash
kubectl rollout history deployment/foma-web
~~~

Rollback:

~~~bash
kubectl rollout undo deployment/foma-web
~~~

Verify:

~~~bash
kubectl rollout status deployment/foma-web
~~~

### Important misconception

You normally do **not** need to manually edit the image back to the old version.

The Deployment keeps revision history.

### Analogy: document version history

If version 5 of a document is broken, you can restore version 4.

You do not rewrite version 4 manually.

Kubernetes Deployment revisions provide a similar operational mechanism.

---

# 16. Production application architecture

A realistic application can look like:

~~~text
                    INTERNET
                       |
                       v
              Ingress / LoadBalancer
                       |
                       v
                    Service
                       |
          +------------+------------+
          |            |            |
          v            v            v
        Pod          Pod          Pod
          |
          +---- ConfigMap
          +---- Secret
          +---- PVC
~~~

The important lesson is separation of concerns:

> **Code, configuration, credentials and persistent data have different lifecycles.**

---

# 17. Troubleshooting methodology

Do not randomly change manifests.

Use a structured workflow.

### Step 1 — What exists?

~~~bash
kubectl get pods -n production
kubectl get deploy -n production
kubectl get rs -n production
kubectl get svc -n production
~~~

### Step 2 — What does Kubernetes report?

~~~bash
kubectl get events -n production --sort-by=.lastTimestamp
~~~

### Step 3 — Inspect the object

~~~bash
kubectl describe pod <pod-name> -n production
~~~

### Step 4 — Read application logs

~~~bash
kubectl logs <pod-name> -n production
kubectl logs <pod-name> -n production --previous
~~~

### Step 5 — Check Service routing

~~~bash
kubectl describe svc foma-web -n production
kubectl get endpoints foma-web -n production
~~~

### Common failures

**Pending:** resources, scheduling or storage.

**ImagePullBackOff:** image name/tag, registry or authentication.

**CrashLoopBackOff:** application startup/runtime failure; inspect current and previous logs.

**Service has no endpoints:** selector/label mismatch, readiness problem or namespace mistake.

**PVC Pending:** StorageClass, capacity, access mode or provisioner issue.

---

# 18. Hands-on lab

Create:

- Namespace;
- Deployment with 3 replicas;
- ClusterIP Service;
- ConfigMap;
- Secret;
- PVC.

Apply:

~~~bash
kubectl apply -f namespace.yaml
kubectl apply -f configmap.yaml
kubectl apply -f secret.yaml
kubectl apply -f pvc.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
~~~

Inspect:

~~~bash
kubectl get all -n production
kubectl get pvc -n production
~~~

Access locally:

~~~bash
kubectl port-forward -n production svc/foma-web 8080:80
~~~

Then practice:

1. Scale from 3 to 5 replicas.
2. Update the image.
3. Watch the rolling update.
4. Inspect rollout history.
5. Roll back.
6. Break the Service selector.
7. Diagnose the missing endpoints.
8. Restore the correct selector.

---

# 19. Production best practices

- Use Deployments for stateless workloads.
- Use StatefulSets when stable identity/storage behavior is required.
- Never depend directly on Pod IPs.
- Use Services for stable application access.
- Keep configuration outside images.
- Treat Secrets as sensitive.
- Define resource requests and limits.
- Use readiness, liveness and startup probes where appropriate.
- Avoid uncontrolled latest image tags in production.
- Keep manifests in Git.
- Use namespaces deliberately.
- Use suitable dynamic storage for production.
- Observe the application after changes.
- Test rollback before an emergency.

---

# 20. Knowledge check

1. What is a Kubernetes application?
2. What is a Pod?
3. What does a Deployment manage?
4. What does a ReplicaSet maintain?
5. When should StatefulSet be considered?
6. Why do we need a Service?
7. What does a Service selector do?
8. What belongs in a ConfigMap?
9. What belongs in a Secret?
10. Is Base64 encryption?
11. What is a PVC?
12. What is a PV?
13. What does StorageClass describe?
14. How do you scale a Deployment?
15. What is HPA?
16. What is a rolling update?
17. How do you inspect rollout history?
18. How do you rollback?
19. Why can a Service have no endpoints?
20. Which command helps inspect recent cluster events?

### Answers

1. A group of Kubernetes resources working together to run an application.
2. The smallest deployable Kubernetes unit.
3. Desired state and lifecycle/rollout of a workload.
4. The desired number of matching Pods.
5. When stable identity and/or stateful storage behavior is required.
6. To provide a stable endpoint for changing Pods.
7. It identifies which Pods receive Service traffic.
8. Non-sensitive configuration.
9. Sensitive information.
10. No; it is encoding.
11. A request for persistent storage.
12. A storage resource available to the cluster.
13. Storage class/provisioning behavior.
14. kubectl scale deployment.
15. Horizontal Pod Autoscaler.
16. Gradual replacement of old Pods with new Pods.
17. kubectl rollout history.
18. kubectl rollout undo.
19. Selector/label mismatch, readiness or configuration problems.
20. kubectl get events --sort-by=.lastTimestamp.

---

# 21. Day 12 challenge

Build a production-style namespace containing:

- 3-replica Deployment;
- ClusterIP Service;
- ConfigMap;
- Secret;
- PVC;
- readiness probe;
- resource requests and limits.

Then:

1. scale to 5 replicas;
2. update the image;
3. monitor the rollout;
4. introduce a controlled failure;
5. troubleshoot it;
6. rollback;
7. explain the responsibility of every Kubernetes object.

### FOMA takeaway

> **Kubernetes applications are not one object. They are cooperating resources, each responsible for a specific part of running, exposing, configuring, scaling and protecting the application.**

**Learn • Practice • Build • Troubleshoot • Advance**

https://foma.life
