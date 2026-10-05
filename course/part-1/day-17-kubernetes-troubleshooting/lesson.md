# Day 17 — Kubernetes Troubleshooting

> **FOMA · William Foma**  
> **DEVOPS FROM ZERO TO PRODUCTION**  
> Troubleshoot from symptoms to root cause — not by guessing.

---

## 1. Learning objectives

You will learn to:

- understand the Kubernetes troubleshooting mindset;
- distinguish Pod, container, Service and node failures;
- investigate Pending, CrashLoopBackOff and ImagePullBackOff;
- use get, describe, logs and Events effectively;
- troubleshoot Services, Ingress and storage;
- build a repeatable incident workflow.

---

## 2. The golden rule

When something breaks:

> **Observe → isolate → test → change → verify.**

Do not randomly edit five manifests.

### Analogy: doctor

A doctor does not prescribe five medicines before examining the patient.

They:

1. collect symptoms;
2. measure;
3. form a hypothesis;
4. test it;
5. treat the cause;
6. verify recovery.

Kubernetes troubleshooting should work the same way.

---

## 3. The troubleshooting map

When a request fails, trace:

~~~text
Client
  |
  v
DNS / Load Balancer
  |
  v
Ingress
  |
  v
Service
  |
  v
Endpoints
  |
  v
Pod
  |
  v
Container
  |
  v
Application
~~~

When a Pod does not run:

~~~text
Manifest
  |
  v
Scheduler
  |
  v
Node
  |
  v
Container runtime
  |
  v
Image
  |
  v
Process
~~~

Use the map to decide where to investigate.

---

## 4. First response commands

Start broad:

~~~bash
kubectl get nodes
kubectl get pods -A
kubectl get svc -A
kubectl get deploy -A
kubectl get events -A --sort-by=.lastTimestamp
~~~

Then narrow:

~~~bash
kubectl get all -n production
~~~

The objective is to understand the current state before changing anything.

---

## 5. Common Pod states

### Running

The Pod is running, but this does not guarantee the application is healthy.

### Pending

The Pod has not successfully reached a running state.

Possible causes:

- insufficient resources;
- scheduling constraints;
- missing PVC;
- taints and tolerations.

### ImagePullBackOff

Kubernetes cannot successfully obtain the image.

Possible causes:

- wrong image;
- wrong tag;
- private registry authentication;
- registry problems.

### CrashLoopBackOff

The container repeatedly starts and crashes.

Possible causes:

- bad configuration;
- application bug;
- missing environment variable;
- failed dependency;
- incorrect command.

---

## 6. kubectl describe

Run:

~~~bash
kubectl describe pod <pod> -n production
~~~

Look at:

- State;
- Last State;
- Reason;
- Events;
- image;
- environment;
- volumes;
- probes.

### Analogy: incident report

A status line is the headline.

describe is the detailed incident report.

---

## 7. Logs

Current logs:

~~~bash
kubectl logs <pod> -n production
~~~

Follow logs:

~~~bash
kubectl logs -f <pod> -n production
~~~

Previous container instance:

~~~bash
kubectl logs <pod> -n production --previous
~~~

Multi-container Pod:

~~~bash
kubectl logs <pod> -c <container> -n production
~~~

For CrashLoopBackOff, previous logs are often extremely useful.

---

## 8. Events

Events can explain scheduling and startup problems:

~~~bash
kubectl get events -n production --sort-by=.lastTimestamp
~~~

Look for messages such as:

~~~text
FailedScheduling
FailedMount
Pulling
BackOff
Unhealthy
~~~

Events are evidence, not a replacement for understanding the application.

---

## 9. Troubleshoot Pending Pods

Start:

~~~bash
kubectl get pod <pod> -n production
kubectl describe pod <pod> -n production
~~~

Then:

~~~bash
kubectl get nodes
kubectl describe nodes
~~~

Example:

~~~text
Pod requests 4 CPU
       |
       v
Node has only 2 CPU available
       |
       v
Pod cannot be scheduled
~~~

### Analogy

A hotel cannot assign a room that does not have enough beds.

---

## 10. Troubleshoot ImagePullBackOff

Run:

~~~bash
kubectl describe pod <pod> -n production
~~~

Check:

- repository name;
- tag;
- registry authentication;
- imagePullSecrets;
- exact error in Events.

Example mistake:

~~~yaml
image: nginx:does-not-exist
~~~

The Pod may be scheduled successfully while the container image cannot be downloaded.

---

## 11. Troubleshoot CrashLoopBackOff

Use:

~~~bash
kubectl logs <pod> -n production --previous
kubectl describe pod <pod> -n production
~~~

Check:

- command;
- environment variables;
- mounted files;
- dependency connectivity;
- ports;
- permissions;
- startup/readiness probes.

Mental model:

~~~text
Pod scheduled
    |
    v
Container starts
    |
    v
Application crashes
    |
    v
Kubernetes restarts it
    |
    v
Application crashes again
    |
    v
Backoff
~~~

The correct fix is usually in the application or configuration.

---

## 12. Readiness vs liveness

### Readiness probe

Answers:

> Should this Pod receive traffic?

### Liveness probe

Answers:

> Is this container healthy enough to keep running?

A failed readiness probe can remove a Pod from Service endpoints without killing it.

A failed liveness probe can cause a restart.

### Analogy

A restaurant worker can be alive but not ready to serve customers.

Alive and ready are different conditions.

---

## 13. Service troubleshooting

Check:

~~~bash
kubectl get svc -n production
kubectl describe svc foma-web -n production
kubectl get endpoints foma-web -n production
~~~

Common problem:

~~~text
Service selector:
app=web

Pod label:
app=frontend
~~~

No match means no endpoints.

### Analogy

The receptionist is told to send visitors to employees wearing blue badges.

Everyone is wearing red badges.

No visitor gets routed.

---

## 14. DNS troubleshooting

Inside a suitable Pod:

~~~bash
nslookup foma-web
~~~

or:

~~~bash
getent hosts foma-web
~~~

Check the Service:

~~~bash
kubectl get svc -n production
~~~

Investigate:

- Service name;
- namespace;
- CoreDNS;
- NetworkPolicies;
- client configuration.

---

## 15. Ingress troubleshooting

Trace:

~~~text
DNS
 |
 v
Ingress Controller
 |
 v
Ingress rule
 |
 v
Service
 |
 v
Endpoints
 |
 v
Pod
~~~

Commands:

~~~bash
kubectl get ingress -A
kubectl describe ingress <name> -n production
kubectl get pods -n ingress-nginx
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller
~~~

A 502/503 requires checking the exact controller behavior and then the Service, endpoints and Pod health.

---

## 16. Storage troubleshooting

For a Pending PVC:

~~~bash
kubectl get pvc -n production
kubectl describe pvc <pvc> -n production
kubectl get storageclass
kubectl get pv
~~~

For a mount failure:

~~~bash
kubectl describe pod <pod> -n production
kubectl get events -n production --sort-by=.lastTimestamp
~~~

Ask:

> Is storage available, claimable, mountable and accessible?

---

## 17. Configuration troubleshooting

If an application has the wrong setting:

~~~bash
kubectl get configmap -n production
kubectl describe configmap foma-config -n production
kubectl get secret -n production
~~~

Then inspect how the Pod consumes the configuration.

Remember:

> Changing a ConfigMap does not necessarily change an already-running process.

If configuration is loaded at startup, the application may require a restart or another reload mechanism.

---

## 18. Node troubleshooting

Check:

~~~bash
kubectl get nodes
kubectl describe node <node>
~~~

Look for:

- Ready condition;
- memory pressure;
- disk pressure;
- taints;
- allocatable resources.

### Analogy

The node is the building hosting workers.

If the building has no capacity, no disk space or serious pressure, applications inside can fail even when their manifests are correct.

---

## 19. Structured incident workflow

~~~text
1. Define symptom
       |
2. Identify scope
       |
3. Check recent changes
       |
4. Inspect objects
       |
5. Read events
       |
6. Read logs
       |
7. Form hypothesis
       |
8. Make one controlled change
       |
9. Verify
       |
10. Document root cause
~~~

This turns troubleshooting into an engineering discipline.

---

## 20. Hands-on incident lab

Deploy the FOMA troubleshooting lab.

### Incident A

Deployment references an invalid image tag.

Find the image error and fix it.

### Incident B

Service selector is intentionally wrong.

Find why endpoints are empty.

### Incident C

A Pod runs a command that exits immediately.

Use logs, previous logs and describe to identify the problem.

---

## 21. Production checklist

### Workload

~~~bash
kubectl get pods -n production
kubectl describe pod <pod> -n production
kubectl logs <pod> -n production
~~~

### Deployment

~~~bash
kubectl rollout status deployment/<name> -n production
kubectl rollout history deployment/<name> -n production
~~~

### Service

~~~bash
kubectl describe svc <name> -n production
kubectl get endpoints <name> -n production
~~~

### Cluster

~~~bash
kubectl get nodes
kubectl get events -A --sort-by=.lastTimestamp
~~~

### Storage

~~~bash
kubectl get pv
kubectl get pvc -A
kubectl get storageclass
~~~

---

## 22. Knowledge check

1. What should you do before changing a manifest?
2. What does Pending mean?
3. What commonly causes ImagePullBackOff?
4. What commonly causes CrashLoopBackOff?
5. Why is describe useful?
6. Why use previous logs?
7. What does readiness mean?
8. What does liveness mean?
9. Why can a Service have no endpoints?
10. What should you inspect for a Pending PVC?
11. Why should troubleshooting be hypothesis-driven?
12. What is the difference between symptom and root cause?

### Answers

1. Observe and isolate the problem.
2. The Pod has not successfully reached a running state.
3. Image name, tag, registry or authentication problems.
4. Repeated application/container failure.
5. It shows detailed state and Events.
6. It shows the previous container instance logs.
7. Whether a Pod should receive traffic.
8. Whether a container is healthy enough to continue.
9. Selector/label mismatch or readiness problems.
10. PVC events, StorageClass, PV, capacity and access requirements.
11. It reduces random changes.
12. A symptom is observed behavior; root cause explains why it happened.

---

## 23. Day 17 challenge

Take a healthy Deployment and intentionally introduce:

1. a bad image tag;
2. a bad Service selector;
3. a failing readiness probe.

For each incident:

- identify the symptom;
- collect evidence;
- state a hypothesis;
- make one fix;
- verify recovery;
- document the root cause.

### FOMA takeaway

> **A strong DevOps engineer is not the person who never sees failures. It is the person who can turn a failure into evidence, identify the root cause and restore service safely.**

**Learn • Practice • Build • Troubleshoot • Advance**

https://foma.life
