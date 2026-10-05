# Day 16 — Kubernetes Security & RBAC

> **FOMA · William Foma**  
> **DEVOPS FROM ZERO TO PRODUCTION**  
> Give the right identity the right access — and nothing more.

---

## 1. Learning objectives

By the end of this lesson, you should be able to:

- explain authentication, authorization and admission;
- define ServiceAccounts;
- explain Kubernetes RBAC;
- create Roles and RoleBindings;
- understand ClusterRole and ClusterRoleBinding;
- test permissions;
- apply least privilege;
- protect Secrets and workloads;
- troubleshoot Forbidden errors.

---

## 2. Why Kubernetes security matters

A Kubernetes cluster can run many applications and many teams.

Without access controls, a developer who only needs to read Pods might accidentally delete a Deployment, read a database password or change a Secret.

Security therefore asks:

> **Who are you, and what are you allowed to do?**

### Analogy: an airport

- Passport check = authentication.
- Boarding pass permissions = authorization.
- Security screening = additional policy/admission controls.

Knowing who you are does not mean you can enter every area.

---

## 3. Authentication

### Definition

**Authentication** establishes identity.

It answers:

> Who is making this request?

Kubernetes can work with identities such as:

- certificates;
- OIDC identities;
- cloud identities;
- ServiceAccounts.

Authentication comes before authorization.

---

## 4. Authorization

### Definition

**Authorization** determines whether an authenticated identity is allowed to perform an action.

It answers:

> Is this identity allowed to do this?

For example:

~~~text
Identity: app-reader
Action: get Pods
Namespace: production
Result: allowed
~~~

RBAC is Kubernetes' standard authorization mechanism.

---

## 5. Admission control

After authentication and authorization, Kubernetes can apply additional policies before accepting a request.

Mental model:

~~~text
Request
  |
  v
Authentication
"Who?"
  |
  v
Authorization
"Allowed?"
  |
  v
Admission
"Should this request be accepted?"
  |
  v
Kubernetes API
~~~

This is useful for enforcing organizational rules.

---

## 6. ServiceAccounts

### Definition

A **ServiceAccount** provides an identity for workloads and automation running inside Kubernetes.

Create one:

~~~bash
kubectl create serviceaccount app-reader -n production
~~~

Inspect it:

~~~bash
kubectl get serviceaccount -n production
~~~

A Pod can use it:

~~~yaml
spec:
  serviceAccountName: app-reader
~~~

### Analogy: employee ID card

A human employee needs an identity.

An application also needs an identity when it must interact with the Kubernetes API.

The ServiceAccount is the workload identity.

---

## 7. RBAC

### Definition

**Role-Based Access Control (RBAC)** grants permissions through roles.

Think:

~~~text
WHO
 +
WHAT
 +
WHERE
~~~

Example:

~~~text
app-reader
can get/list/watch Pods
in production
~~~

RBAC is primarily additive: permissions are granted through rules.

---

## 8. Role

### Definition

A **Role** defines permissions within one namespace.

Example:

~~~yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: production
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "list", "watch"]
~~~

This says the role allows reading Pods in the production namespace.

A Role does not automatically grant its permissions to anyone. A subject must be bound to it.

---

## 9. RoleBinding

### Definition

A **RoleBinding** connects a subject to a Role.

~~~yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: app-reader-binding
  namespace: production
subjects:
  - kind: ServiceAccount
    name: app-reader
    namespace: production
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
~~~

Mental model:

~~~text
ServiceAccount
      |
      v
RoleBinding
      |
      v
Role
      |
      v
Permissions
~~~

### Analogy: job assignment

The Role is the job description.

The RoleBinding assigns the employee to that job.

---

## 10. ClusterRole

### Definition

A **ClusterRole** defines permissions that can be used for cluster-scoped resources or reused across namespaces.

Example:

~~~yaml
kind: ClusterRole
metadata:
  name: node-reader
rules:
  - apiGroups: [""]
    resources: ["nodes"]
    verbs: ["get", "list", "watch"]
~~~

Nodes are cluster-scoped resources.

---

## 11. ClusterRoleBinding

### Definition

A **ClusterRoleBinding** grants a ClusterRole at cluster scope.

Be careful:

> Cluster-wide access is much more powerful than namespace-scoped access.

Use it only when the workload genuinely requires it.

---

## 12. Role vs ClusterRole

| Object | Scope | Typical use |
|---|---|---|
| Role | Namespace | Read Pods in production |
| RoleBinding | Namespace | Attach a Role |
| ClusterRole | Cluster/reusable | Read Nodes or reusable rules |
| ClusterRoleBinding | Cluster | Grant cluster-wide access |

### Rule

> **Start with the smallest scope that solves the problem.**

---

## 13. RBAC verbs

Common verbs include:

- get
- list
- watch
- create
- update
- patch
- delete

A monitoring application may need:

~~~yaml
verbs: ["get", "list", "watch"]
~~~

It normally should not receive unrestricted access.

---

## 14. Least privilege

### Definition

**Least privilege** means giving an identity only the permissions required for its job.

Bad:

~~~text
Application
   |
   v
cluster-admin
~~~

Better:

~~~text
Application
   |
   v
read required resources
in required namespace
~~~

### Analogy: house keys

Do not give a delivery driver the master key to your entire house.

Give access only to the door they need.

---

## 15. Testing permissions

Use:

~~~bash
kubectl auth can-i get pods \
  --as=system:serviceaccount:production:app-reader \
  -n production
~~~

Test an action that should be denied:

~~~bash
kubectl auth can-i delete deployments \
  --as=system:serviceaccount:production:app-reader \
  -n production
~~~

This command is one of the most useful tools for learning and troubleshooting RBAC.

---

## 16. Secrets and RBAC

Secrets deserve special protection.

A user or workload that can read Secrets may obtain credentials.

Therefore:

~~~text
Secret
  |
  v
RBAC protection
  |
  v
Only required identities
~~~

Do not grant broad Secret access simply because an application might need one credential.

---

## 17. Security is layered

RBAC is only one layer.

Also consider:

- non-root containers;
- read-only filesystems where practical;
- dropped Linux capabilities;
- seccomp;
- NetworkPolicies;
- image scanning;
- trusted registries;
- Secret protection;
- resource limits;
- admission policies.

Mental model:

~~~text
Identity
  +
RBAC
  +
Pod security
  +
Network security
  +
Image security
  +
Secret protection
~~~

---

## 18. Troubleshooting Forbidden errors

If Kubernetes returns:

~~~text
Error from server (Forbidden)
~~~

Do not immediately grant admin access.

Ask:

1. Who is making the request?
2. What verb is required?
3. What resource is being accessed?
4. Which namespace is involved?
5. Which Role should provide access?
6. Is the Binding correct?
7. Is the API group correct?

Useful commands:

~~~bash
kubectl auth can-i get pods -n production
kubectl get role -n production
kubectl get rolebinding -n production
kubectl describe role pod-reader -n production
kubectl describe rolebinding app-reader-binding -n production
~~~

---

## 19. Hands-on lab

Apply:

~~~bash
kubectl apply -f namespace.yaml
kubectl apply -f serviceaccount.yaml
kubectl apply -f role.yaml
kubectl apply -f rolebinding.yaml
~~~

Verify:

~~~bash
kubectl get sa -n production
kubectl get role -n production
kubectl get rolebinding -n production
~~~

Test:

~~~bash
kubectl auth can-i get pods \
  --as=system:serviceaccount:production:app-reader \
  -n production

kubectl auth can-i delete pods \
  --as=system:serviceaccount:production:app-reader \
  -n production
~~~

The first should be allowed and the second should be denied.

---

## 20. Production best practices

- Prefer namespace-scoped Roles.
- Avoid cluster-admin for applications.
- Use dedicated ServiceAccounts.
- Review RoleBindings regularly.
- Protect Secrets with least privilege.
- Test authorization before production.
- Keep RBAC manifests in Git.
- Run containers as non-root where practical.
- Combine RBAC with network and workload security.

---

## 21. Knowledge check

1. What is authentication?
2. What is authorization?
3. What is RBAC?
4. What is a ServiceAccount?
5. What does a Role define?
6. What connects a subject to a Role?
7. When is ClusterRole useful?
8. What is least privilege?
9. What does kubectl auth can-i test?
10. Why is Secret access sensitive?
11. Why is cluster-admin dangerous?
12. What should you inspect after a Forbidden error?

### Answers

1. Establishing identity.
2. Determining whether an identity is allowed to perform an action.
3. Role-based authorization.
4. An identity for workloads and automation.
5. Namespace-scoped permissions.
6. RoleBinding.
7. Cluster-scoped resources or reusable permissions.
8. Granting only required access.
9. Whether an identity can perform an API action.
10. Secrets can contain credentials.
11. It provides very broad privileges.
12. Identity, verb, resource, namespace, Role and Binding.

---

## 22. Day 16 challenge

Design access for a monitoring application that needs:

- read Pods;
- read Deployments;
- read Services;
- watch changes;
- no Secret access;
- no delete permissions.

Create the ServiceAccount, Role and RoleBinding.

Then prove the design using kubectl auth can-i.

### FOMA takeaway

> **Security is not about giving everyone enough access. It is about giving every identity exactly the access it needs.**

**Learn • Practice • Build • Troubleshoot • Advance**

https://foma.life
