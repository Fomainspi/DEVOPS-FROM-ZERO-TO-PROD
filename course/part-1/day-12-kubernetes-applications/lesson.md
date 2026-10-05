# Day 12 — Kubernetes Applications

> FOMA · William Foma · Deploy, scale and manage real-world applications

## 1. The application mental model

A production application is normally more than a Pod:

**Deployment → ReplicaSet → Pods**  
**Service → stable network endpoint**  
**ConfigMap / Secret → configuration**  
**PVC → persistent data**

Kubernetes continuously works to make the actual state match the desired state.

## 2. Deployment, ReplicaSet and StatefulSet

A Deployment is normally used for stateless applications such as web servers and APIs.

~~~yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: foma-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: foma-app
  template:
    metadata:
      labels:
        app: foma-app
    spec:
      containers:
        - name: web
          image: nginx:1.25
          ports:
            - containerPort: 80
~~~

A Deployment manages ReplicaSets. A ReplicaSet maintains the requested number of matching Pods.

Use a StatefulSet when stable identity and/or persistent storage is part of the workload design, for example a database or clustered stateful system.

**Rule:** do not create ReplicaSets directly for normal application delivery. Let the Deployment manage them.

## 3. Services

Pods are replaceable and their IP addresses can change. A Service provides a stable endpoint.

~~~yaml
apiVersion: v1
kind: Service
metadata:
  name: foma-app
spec:
  selector:
    app: foma-app
  ports:
    - port: 80
      targetPort: 80
  type: ClusterIP
~~~

Development test:

~~~bash
kubectl port-forward svc/foma-app 8080:80
~~~

## 4. ConfigMaps and Secrets

Use ConfigMaps for non-sensitive configuration:

~~~yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: foma-config
data:
  APP_ENV: production
  LOG_LEVEL: info
~~~

Use Secrets for sensitive values:

~~~yaml
apiVersion: v1
kind: Secret
metadata:
  name: foma-secret
type: Opaque
stringData:
  DB_PASSWORD: change-me
~~~

A critical security point: base64 encoding is not encryption. Protect Secrets with RBAC, encryption at rest and appropriate secret-management controls.

## 5. Persistent storage

The relationship is:

**Pod → PVC → PV → StorageClass / storage backend**

A PVC requests storage:

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

For production, prefer dynamic provisioning through a suitable StorageClass instead of relying on hostPath.

## 6. Scaling

Manual scaling:

~~~bash
kubectl scale deployment foma-app --replicas=5
kubectl get pods -l app=foma-app
~~~

HPA can scale dynamically when metrics are available:

~~~bash
kubectl autoscale deployment foma-app --cpu-percent=70 --min=2 --max=10
kubectl get hpa
~~~

## 7. Rolling updates and rollback

~~~bash
kubectl set image deployment/foma-app web=nginx:1.26
kubectl rollout status deployment/foma-app
kubectl rollout history deployment/foma-app
kubectl rollout undo deployment/foma-app
~~~

Production flow:

**Change → rollout → observe → validate → keep or rollback**

Readiness probes help prevent traffic from reaching an application that is not ready.

## 8. Troubleshooting workflow

Start broad:

~~~bash
kubectl get pods -o wide
kubectl get deploy,rs,svc
kubectl get events --sort-by=.lastTimestamp
~~~

Then inspect:

~~~bash
kubectl describe pod <pod-name>
kubectl logs <pod-name>
kubectl logs <pod-name> --previous
~~~

For networking:

~~~bash
kubectl describe svc foma-app
kubectl get endpoints foma-app
~~~

If a Service has no endpoints, compare its selector with the Pod labels.

### Common failures

**Pending:** inspect scheduling events, resources and storage.  
**ImagePullBackOff:** verify image name/tag and registry access.  
**CrashLoopBackOff:** inspect current and previous logs.  
**PVC Pending:** inspect StorageClass, capacity and access mode.  
**Service unavailable:** verify selector, endpoints and targetPort.

## 9. Hands-on lab

~~~bash
kubectl apply -f namespace.yaml
kubectl apply -f configmap.yaml
kubectl apply -f secret.yaml
kubectl apply -f pvc.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

kubectl get all -n production
kubectl get pvc -n production
kubectl port-forward -n production svc/foma-app 8080:80
~~~

Then scale to five replicas, perform an image update and demonstrate a rollback.

## 10. Production best practices

- Deploy stateless applications with Deployments.
- Use StatefulSets only when stable identity/storage is required.
- Keep configuration outside images.
- Treat Secrets as sensitive.
- Define requests and limits.
- Add readiness/liveness/startup probes where appropriate.
- Avoid the latest image tag in production.
- Keep manifests in Git.
- Use namespaces and appropriate StorageClasses.
- Observe before changing.

## Knowledge check

1. What does a Deployment manage?
2. Why is a Service needed?
3. When is StatefulSet appropriate?
4. What belongs in a ConfigMap?
5. Why is base64 not encryption?
6. What does a PVC represent?
7. How do you scale a Deployment?
8. How do you rollback?
9. What does kubectl get events reveal?
10. What must match for a Service to select Pods?

**Answers:** Deployment manages ReplicaSets; Service provides a stable endpoint; StatefulSet supports stateful identity/storage; ConfigMap stores non-sensitive configuration; base64 is encoding; PVC requests storage; use kubectl scale; use kubectl rollout undo; events reveal cluster/application lifecycle problems; Service selectors must match Pod labels.

## Day 12 challenge

Create a production namespace with a three-replica application, Service, ConfigMap, Secret and PVC. Scale to five replicas, update the image, verify the rollout and demonstrate rollback.

**FOMA takeaway:** Kubernetes applications are collections of desired-state resources working together.

Learn • Practice • Build • Advance  
https://foma.life
