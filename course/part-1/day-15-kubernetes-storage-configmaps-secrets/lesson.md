# Day 15 — Kubernetes Storage, ConfigMaps & Secrets

> **FOMA · William Foma**  
> **DEVOPS FROM ZERO TO PRODUCTION**  
> Separate application code, configuration, credentials and persistent data.

---

## 1. Learning objectives

You will learn to:

- explain why Pod storage is not automatically persistent;
- define PV, PVC and StorageClass;
- understand storage lifecycles;
- distinguish temporary and persistent volumes;
- create and mount a PVC;
- use ConfigMaps;
- use Secrets safely;
- understand why Base64 is not encryption;
- troubleshoot storage and configuration failures;
- design a basic application + database storage pattern.

---

# 2. The big idea

A production application normally has four different categories:

~~~text
APPLICATION CODE
      |
      v
Container image

CONFIGURATION
      |
      v
ConfigMap

CREDENTIALS
      |
      v
Secret

PERSISTENT DATA
      |
      v
PVC → PV → storage backend
~~~

These should not be treated as the same thing.

### Analogy: moving house

When you move to a new house:

- furniture is data that should survive;
- instructions/settings are configuration;
- keys/passwords are secrets;
- the building itself is the application environment.

If the house changes, your important belongings should not disappear.

Pods are replaceable in a similar way.

---

# 3. Why container storage can disappear

A container can write files to its writable filesystem.

But containers and Pods are designed to be replaceable.

Suppose:

~~~text
/uploads/photo.jpg
~~~

exists only inside a Pod.

If the Pod is deleted and a new Pod is created, that file may not exist in the new Pod.

Therefore ask:

> **Where should important data live when the Pod disappears?**

If the answer is "it must survive", use persistent storage.

---

# 4. Volume

### Definition

A **volume** provides storage that can be mounted into a Pod.

Different volume types have different lifecycles.

Some are temporary.

Some are backed by persistent storage.

The important distinction is:

> **Container filesystem and persistent application storage are not automatically the same thing.**

---

# 5. emptyDir

### Definition

emptyDir creates temporary storage associated with the lifetime of a Pod.

It is useful for:

- temporary files;
- caches;
- scratch space;
- sharing temporary data between containers in one Pod.

When the Pod is removed, the emptyDir data is removed.

### Analogy: whiteboard

A team writes temporary information on a whiteboard.

When the room disappears, the notes disappear too.

Use emptyDir when that behavior is acceptable.

---

# 6. hostPath

### Definition

hostPath mounts a path from the Kubernetes node filesystem into a Pod.

Conceptually:

~~~text
Node
/data/foma
    |
    v
Pod volume
~~~

Useful for:

- learning;
- local development;
- specialized node-level workloads.

### Why is it risky for general production?

The data is tied to a node.

If the Pod moves to another node:

~~~text
Node A
/data/foma
     |
     X
Pod moves
     |
     v
Node B
/data/foma
~~~

Node B may not contain the same data.

### Analogy

It is like storing company documents only on one employee's laptop.

If the employee changes laptops, the documents may not follow automatically.

---

# 7. PersistentVolume

### Definition

A **PersistentVolume (PV)** is a storage resource available to the Kubernetes cluster.

The actual backend may be:

- cloud block storage;
- network storage;
- a storage appliance;
- local storage;
- another supported system.

### Analogy: warehouse storage unit

A PV is like a storage unit available in a warehouse.

The application does not need to manage every physical detail of the warehouse.

---

# 8. PersistentVolumeClaim

### Definition

A **PersistentVolumeClaim (PVC)** is a request for storage made by a workload.

Example:

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

The workload is saying:

> "I need 1 GiB of storage with these requirements."

### Analogy: rental request

- PV = available storage unit.
- PVC = rental request.
- Pod = customer using the storage.

---

# 9. StorageClass

### Definition

A **StorageClass** describes a class of storage and how storage can be dynamically provisioned.

A platform might offer:

~~~text
standard
fast-ssd
high-performance
~~~

A PVC can request an appropriate class.

### Analogy: storage catalog

A storage company offers several types of storage.

The catalog describes what each type provides and how it is supplied.

The StorageClass serves a similar purpose in Kubernetes.

---

# 10. Complete storage relationship

Remember:

~~~text
Pod
 |
 | uses
 v
PVC
 |
 | requests
 v
PV
 |
 | may be dynamically supplied by
 v
StorageClass
 |
 v
Storage backend
~~~

### Definitions

**PV** = storage resource.

**PVC** = request for storage.

**StorageClass** = storage provisioning class/policy.

**Pod** = consumer.

---

# 11. Access modes

Common access modes include:

- **ReadWriteOnce (RWO)** — read/write access associated with one node, depending on storage implementation.
- **ReadOnlyMany (ROX)** — read-only access from multiple nodes, where supported.
- **ReadWriteMany (RWX)** — read/write access from multiple nodes, where supported.

Do not assume that every storage backend supports every mode.

### Production lesson

Access modes depend on the storage implementation and topology.

---

# 12. ConfigMaps

### Definition

A **ConfigMap** stores non-sensitive configuration outside the container image.

Examples:

~~~text
APP_ENV=production
LOG_LEVEL=info
API_URL=https://api.foma.life
FEATURE_X_ENABLED=true
~~~

Example:

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

### Why?

The same application image can run in:

~~~text
Development
Staging
Production
~~~

with different configuration.

You should not rebuild the image merely because a configuration value changes.

### Analogy: machine settings

The machine is the same.

The operating settings can change.

The application image is the machine; the ConfigMap provides external settings.

---

# 13. How Pods consume ConfigMaps

### Environment variables

~~~yaml
envFrom:
  - configMapRef:
      name: foma-config
~~~

### Individual key

~~~yaml
env:
  - name: APP_ENV
    valueFrom:
      configMapKeyRef:
        name: foma-config
        key: APP_ENV
~~~

### Files

A ConfigMap can also be mounted as files.

Choose the method based on how the application expects configuration.

---

# 14. Secrets

### Definition

A **Secret** is a Kubernetes object intended for sensitive information.

Examples:

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
  namespace: production
type: Opaque
stringData:
  DB_USERNAME: app
  DB_PASSWORD: change-me
~~~

### Critical security lesson

**Base64 is encoding, not encryption.**

Conceptually:

~~~text
secret
  |
  v
Base64
  |
  v
c2VjcmV0
  |
  v
decode
  |
  v
secret
~~~

Therefore a Base64 value should not be treated as a password-protection mechanism.

Production security should include:

- least-privilege RBAC;
- encryption at rest;
- restricted access;
- credential rotation;
- external secret-management systems where appropriate.

### Analogy: key cabinet

ConfigMap is like a public office instruction.

Secret is like the key to the office.

Both are configuration, but the Secret needs much tighter access control.

---

# 15. ConfigMap vs Secret

| | ConfigMap | Secret |
|---|---|---|
| Purpose | Non-sensitive configuration | Sensitive information |
| Example | LOG_LEVEL | DB_PASSWORD |
| Credentials | No | Yes |
| Access control | Important | Critical |
| Real secrets in Git | No need | Never |
| Base64 | Not a security feature | Not encryption |

---

# 16. Mounting a PVC

Example:

~~~yaml
apiVersion: v1
kind: Pod
metadata:
  name: foma-app
spec:
  containers:
    - name: web
      image: nginx:1.25
      volumeMounts:
        - name: data
          mountPath: /var/lib/foma
  volumes:
    - name: data
      persistentVolumeClaim:
        claimName: foma-data
~~~

The relationship is:

~~~text
Container
   |
   v
volumeMount
   |
   v
Pod volume
   |
   v
PVC
   |
   v
Persistent storage
~~~

---

# 17. Real-world web application + database

A simple production-style model:

~~~text
                  Web/API Deployment
                         |
                       Service
                         |
                 +-------+-------+
                 |       |       |
                Pod     Pod     Pod
                 |
        +--------+---------+
        |        |         |
        v        v         v
    ConfigMap  Secret     PVC
                           |
                           v
                     Persistent data


                 Database StatefulSet
                    |       |       |
                    v       v       v
                  PVC-0   PVC-1   PVC-2
~~~

### Important distinction

Persistence is **not** backup.

A persistent disk can survive a Pod restart but still be lost through:

- accidental deletion;
- corruption;
- operator error;
- application bugs;
- disaster.

Production databases need tested backup and restore procedures.

---

# 18. Troubleshooting PVC Pending

Run:

~~~bash
kubectl get pvc -n production
kubectl describe pvc foma-data -n production
kubectl get storageclass
kubectl get pv
kubectl get events -n production --sort-by=.lastTimestamp
~~~

Check:

- requested size;
- access mode;
- StorageClass;
- provisioner;
- available capacity;
- topology constraints.

### Analogy

If a storage rental request is still pending, ask:

> "Why has no suitable storage unit been assigned?"

---

# 19. Troubleshooting mount failures

Inspect the Pod:

~~~bash
kubectl describe pod <pod> -n production
~~~

Then:

~~~bash
kubectl get events -n production --sort-by=.lastTimestamp
~~~

Look for:

- missing PVC;
- wrong volume name;
- unsupported access mode;
- storage backend failure;
- permission problems.

---

# 20. Configuration appears stale

Suppose you change:

~~~text
LOG_LEVEL=debug
~~~

but the running application still uses:

~~~text
LOG_LEVEL=info
~~~

First determine how the application consumes the ConfigMap.

Environment variables are commonly loaded into a process when the container starts.

Changing the ConfigMap does not automatically change the environment of an already-running process.

The application may need a restart/recreation or another explicit configuration-reload mechanism.

---

# 21. Secret access failure

Check:

~~~bash
kubectl get secret -n production
kubectl describe secret foma-secret -n production
kubectl get pods -n production
~~~

Verify:

- Secret name;
- namespace;
- Pod reference;
- RBAC permissions;
- application configuration.

Do not print real secret values into logs just to verify them.

---

# 22. Hands-on lab

The FOMA lab uses simple local storage intentionally for learning.

### Step 1 — Namespace

~~~bash
kubectl apply -f namespace.yaml
~~~

### Step 2 — Storage

~~~bash
kubectl apply -f pv.yaml
kubectl apply -f pvc.yaml
kubectl get pv
kubectl get pvc -n production
~~~

### Step 3 — Configuration

~~~bash
kubectl apply -f configmap.yaml
kubectl apply -f secret.yaml
~~~

### Step 4 — Pod

~~~bash
kubectl apply -f pod.yaml
kubectl get pods -n production
~~~

### Step 5 — Enter the Pod

~~~bash
kubectl exec -it foma-app -n production -- sh
~~~

Inside:

~~~bash
df -h
ls -la /var/lib/foma
echo "FOMA persistent data" > /var/lib/foma/test.txt
cat /var/lib/foma/test.txt
~~~

### Step 6 — Delete and recreate the Pod

~~~bash
kubectl delete pod foma-app -n production
kubectl apply -f pod.yaml
~~~

Check whether the file is still available.

The learning objective is to observe that the file belongs to the persistent storage rather than only to the disposable Pod.

---

# 23. Production best practices

### Storage

- Prefer appropriate dynamic provisioning.
- Understand the storage backend.
- Choose access modes deliberately.
- Monitor capacity and performance.
- Define backup and restore procedures.
- Test restoration.
- Avoid hostPath as a general production storage strategy.

### Configuration

- Keep non-sensitive configuration outside images.
- Version configuration changes.
- Use environment-specific configuration.
- Understand how the application reloads configuration.

### Secrets

- Never commit real credentials to Git.
- Use least-privilege RBAC.
- Protect encryption at rest.
- Rotate credentials.
- Consider external secret management.
- Avoid printing secrets in logs.

---

# 24. Knowledge check

1. Why can Pod-local data disappear?
2. What is emptyDir?
3. What is hostPath?
4. What is a PV?
5. What is a PVC?
6. What does StorageClass provide?
7. What does RWO mean?
8. What belongs in a ConfigMap?
9. What belongs in a Secret?
10. Is Base64 encryption?
11. How does a Pod use a PVC?
12. Why can a PVC remain Pending?
13. Why is persistence not backup?
14. Why can a changed ConfigMap appear stale?
15. What should you inspect when Secret access fails?

### Answers

1. Pods can be deleted and recreated.
2. Temporary Pod-associated storage.
3. A node filesystem path exposed to a Pod.
4. A persistent storage resource.
5. A request for persistent storage.
6. A storage class/provisioning policy.
7. Read/write access associated with one node, depending on backend semantics.
8. Non-sensitive configuration.
9. Sensitive information.
10. No.
11. Through a volume that references the PVC.
12. Storage, capacity, access mode, class, provisioner or topology problems.
13. Persistence does not protect against deletion, corruption or disaster.
14. The running process may already have its environment loaded.
15. Name, namespace, reference, RBAC and application configuration.

---

# 25. Day 15 challenge

Build a namespace containing:

- ConfigMap;
- Secret;
- PVC;
- application Pod.

Then:

1. mount the PVC;
2. write a test file;
3. delete the Pod;
4. recreate it;
5. verify the file;
6. change a ConfigMap value;
7. observe application behavior;
8. explain why code, configuration, secrets and persistent data have different lifecycles.

### FOMA takeaway

> **Production Kubernetes separates code, configuration, secrets and persistent data. Once you understand that separation, storage and configuration become much easier to reason about.**

**Learn • Practice • Build • Troubleshoot • Advance**

https://foma.life
