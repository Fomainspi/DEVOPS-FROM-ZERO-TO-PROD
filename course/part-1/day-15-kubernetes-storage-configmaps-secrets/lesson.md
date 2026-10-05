# Day 15 — Kubernetes Storage, ConfigMaps & Secrets

> FOMA · William Foma · Manage application data and configuration securely

## 1. Storage mental model

**Pod → PVC → PV → StorageClass / storage backend**

Pods are replaceable; application data often must survive Pod replacement.

## 2. PersistentVolume and PersistentVolumeClaim

A PV represents storage available to the cluster. A PVC is a workload's request for storage.

~~~yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: foma-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
~~~

Inspect:

~~~bash
kubectl get pv
kubectl get pvc
kubectl describe pvc foma-pvc
~~~

For production, prefer dynamic provisioning through a suitable StorageClass rather than hostPath.

## 3. StorageClass

A StorageClass describes how storage is dynamically provisioned.

~~~bash
kubectl get storageclass
kubectl describe storageclass <name>
~~~

Choose storage deliberately for durability, access mode, performance and platform.

## 4. Volume types

- **emptyDir** — temporary Pod storage.
- **hostPath** — node filesystem path; mainly learning/specialized use.
- **PV/PVC** — persistent storage abstraction.
- **StorageClass** — dynamic provisioning policy.

## 5. ConfigMaps

Use ConfigMap for non-sensitive configuration:

~~~yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: foma-config
  namespace: production
data:
  APP_ENV: production
  LOG_LEVEL: info
  API_URL: https://api.foma.life
~~~

Consume it as environment variables:

~~~yaml
envFrom:
  - configMapRef:
      name: foma-config
~~~

Or mount it as files.

## 6. Secrets

Use Secret for sensitive values:

~~~yaml
apiVersion: v1
kind: Secret
metadata:
  name: foma-secret
  namespace: production
type: Opaque
stringData:
  DB_USERNAME: app
  DB_PASSWORD: change-me
~~~

**Base64 encoding is not encryption.** Production controls should include RBAC, encryption at rest, restricted access, rotation and appropriate external secret-management solutions.

## 7. Mount a PVC in a Pod

~~~yaml
volumeMounts:
  - name: data
    mountPath: /var/lib/foma
volumes:
  - name: data
    persistentVolumeClaim:
      claimName: foma-pvc
~~~

Inspect:

~~~bash
kubectl exec -it <pod> -- sh
df -h
ls -la /var/lib/foma
~~~

## 8. Real-world pattern

~~~text
Web/API Pod
├── ConfigMap → application settings
├── Secret    → credentials
└── PVC       → persistent application data

Database StatefulSet
└── PVC per replica
~~~

Persistence is not backup. Production databases also need tested backup and recovery.

## 9. Troubleshooting

### PVC Pending

~~~bash
kubectl describe pvc foma-pvc -n production
kubectl get storageclass
kubectl get pv
~~~

Check capacity, access mode, StorageClass and provisioner.

### Mount failure

~~~bash
kubectl describe pod <pod> -n production
kubectl get events -n production --sort-by=.lastTimestamp
~~~

### Configuration appears stale

Environment variables are normally fixed for the container lifetime. Restart/recreate Pods when the application requires changed values.

### Secret access failure

Check namespace, Secret name and workload permissions/RBAC.

## 10. Hands-on practice

Apply the lab manifests, verify the PVC is Bound, enter the Pod, write a file to the mounted volume, delete/recreate the Pod and test persistence.

~~~bash
kubectl apply -f namespace.yaml
kubectl apply -f pv.yaml
kubectl apply -f pvc.yaml
kubectl apply -f configmap.yaml
kubectl apply -f secret.yaml
kubectl apply -f pod.yaml

kubectl get pv
kubectl get pvc -n production
kubectl get pods -n production
kubectl exec -it foma-app -n production -- sh
~~~

## Production best practices

- Prefer dynamic provisioning with a suitable StorageClass.
- Avoid hostPath as a general production storage solution.
- Define backup and restore procedures.
- Monitor capacity and performance.
- Separate sensitive and non-sensitive configuration.
- Restrict Secret access with RBAC.
- Rotate credentials.
- Never commit real credentials to Git.
- Test restoration, not only backup creation.
- Choose access modes deliberately.

## Knowledge check

1. PV versus PVC?
2. What does StorageClass provide?
3. Which volume is normally temporary?
4. Why is hostPath unsuitable for general production?
5. What belongs in ConfigMap?
6. What belongs in Secret?
7. Is base64 encryption?
8. How does a Pod consume a PVC?
9. Why is persistence not a backup?
10. What should you inspect when a PVC is Pending?

**Answers:** PV is cluster storage and PVC is a request; StorageClass provides provisioning policy; emptyDir is temporary; hostPath ties data to a node; ConfigMap stores non-sensitive configuration; Secret stores sensitive values; base64 is not encryption; a Pod mounts a PVC through a volume; backups provide recovery; inspect events, StorageClass, capacity, access modes and PV/provisioner.

## Day 15 challenge

Create a namespace containing a ConfigMap, Secret, PVC and Pod. Write a test file to the mounted volume. Delete and recreate the Pod. Verify what survives and explain why.

**FOMA takeaway:** Separate code, configuration, secrets and persistent data.

Learn • Practice • Build • Advance  
https://foma.life
