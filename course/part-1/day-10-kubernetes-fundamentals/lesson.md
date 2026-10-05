# Day 10 — Kubernetes Fundamentals

> **FOMA — DEVOPS FROM ZERO TO PRODUCTION**

## 1. Mission

Docker packages an application. Kubernetes coordinates containers across a cluster and continuously works toward a declared desired state.

### Objectives
- Understand Kubernetes architecture.
- Use kubectl effectively.
- Work with Namespaces, Pods, Deployments and ReplicaSets.
- Expose applications with Services.
- Use ConfigMaps and Secrets.
- Scale, roll out, and roll back applications.
- Troubleshoot common workload problems.

## 2. Kubernetes architecture

~~~text
CONTROL PLANE
API Server | Scheduler | Controllers | etcd
                 |
        -----------------
        |               |
     WORKER          WORKER
  kubelet/runtime  kubelet/runtime
     kube-proxy       kube-proxy
       Pods             Pods
~~~

**API server** is the cluster API. **etcd** stores cluster state. **Scheduler** places new Pods. **Controllers** reconcile desired and observed state. Worker nodes run Pods through a container runtime; kubelet manages them and kube-proxy supports Service networking.

The key mental model is:

~~~text
desired state → API → controllers → cluster state
                           ↑
                     continuous reconcile
~~~

## 3. kubectl fundamentals

~~~bash
kubectl version --client
kubectl cluster-info
kubectl get nodes
kubectl get pods -A
kubectl get svc -A
kubectl get deployments -A
kubectl describe pod <pod>
kubectl logs <pod>
kubectl get events --sort-by=.lastTimestamp
~~~

Use **get** for a quick view, **describe** for object details/events, and **logs** for application output.

~~~bash
kubectl api-resources
kubectl explain deployment
kubectl explain deployment.spec
~~~

## 4. Namespaces and contexts

~~~bash
kubectl get ns
kubectl create namespace devops
kubectl get all -n devops
kubectl config get-contexts
kubectl config current-context
kubectl config use-context <context>
~~~

Make the namespace explicit during practice:

~~~bash
kubectl get pods -n devops
~~~

## 5. Pods

A Pod is the smallest deployable unit in Kubernetes. Containers in a Pod share networking and can share volumes.

~~~bash
kubectl run nginx --image=nginx -n devops
kubectl get pods -n devops -o wide
kubectl describe pod nginx -n devops
kubectl logs nginx -n devops
kubectl delete pod nginx -n devops
~~~

For stateless applications, prefer a Deployment rather than manually managing Pods.

## 6. Deployments and ReplicaSets

~~~bash
kubectl create deployment web --image=nginx -n devops
kubectl scale deployment web --replicas=3 -n devops
kubectl get deployment,replicaset,pods -n devops
~~~

~~~text
Deployment → ReplicaSet → Pods
~~~

The Deployment manages revisions and desired state. The ReplicaSet maintains the requested number of matching Pods.

## 7. Services

Pods are replaceable, so their IP addresses are not stable application endpoints.

~~~bash
kubectl expose deployment web --port=80 --type=ClusterIP -n devops
kubectl get svc -n devops
kubectl get endpoints -n devops
~~~

| Type | Typical purpose |
|---|---|
| ClusterIP | Internal cluster access |
| NodePort | Simple external node-port access |
| LoadBalancer | External load-balancer integration when supported |

A Service selects Pods using labels and provides a stable endpoint.

## 8. ConfigMaps and Secrets

~~~bash
kubectl create configmap app-config --from-literal=ENV=prod -n devops
kubectl create secret generic app-secret --from-literal=API_KEY=change-me -n devops
kubectl get configmap app-config -n devops
kubectl get secret app-secret -n devops
~~~

Do not commit plaintext production secrets to Git. Kubernetes Secrets require appropriate access controls and secure handling; base64 encoding alone is not encryption.

## 9. Scaling, rolling updates and rollback

~~~bash
kubectl scale deployment web --replicas=5 -n devops
kubectl set image deployment/web nginx=nginx:1.27 -n devops
kubectl rollout status deployment/web -n devops
kubectl rollout history deployment/web -n devops
kubectl rollout undo deployment/web -n devops
~~~

You change desired state; Kubernetes controllers work to make reality match it.

## 10. Troubleshooting workflow

### Pending
~~~bash
kubectl describe pod <pod> -n devops
kubectl get events -n devops --sort-by=.lastTimestamp
~~~

Look for scheduling, resources, storage, or policy errors.

### ImagePullBackOff
Check image name/tag, registry access, and image-pull credentials.

### CrashLoopBackOff
~~~bash
kubectl logs <pod> -n devops
kubectl logs <pod> -n devops --previous
~~~

### Running but unavailable
Check the application port, readiness, Service selector, endpoints, and networking.

Use this order:

~~~text
status → describe → logs → events → service → endpoints
~~~

## 11. Hands-on practice

On a disposable Minikube or lab cluster:
1. Create namespace devops.
2. Create an nginx Deployment with 3 replicas.
3. Verify Deployment, ReplicaSet and Pods.
4. Expose it as ClusterIP.
5. Scale to 5 replicas.
6. Update the image.
7. Watch rollout status.
8. Inspect rollout history.
9. Roll back.
10. Create a ConfigMap.
11. Create a Secret without committing it to Git.
12. Break a test workload and troubleshoot it with evidence.

### Knowledge check
1. What does the API server do?
2. What is stored in etcd?
3. What does the scheduler do?
4. Why are Pods ephemeral?
5. Why use a Deployment?
6. What does a ReplicaSet maintain?
7. Why use a Service?
8. What is a Namespace?
9. ConfigMap vs Secret?
10. What command rolls back a Deployment?
11. Where do you investigate a Pending Pod?
12. Logs vs describe?

## Golden rules

- Declare desired state; let controllers reconcile it.
- Prefer Deployments for stateless applications.
- Use labels consistently.
- Make namespaces explicit.
- Never treat Pod IPs as permanent.
- Keep secrets out of source control.
- Troubleshoot status → describe → logs → events → endpoints.
- Change one thing at a time.

**Next:** Day 11 — Helm & Kubernetes Packaging

**William Foma | FOMA | https://foma.life**
