# Day 14 — Kubernetes Ingress & Networking

> **FOMA · William Foma**  
> **DEVOPS FROM ZERO TO PRODUCTION**  
> Trace traffic from the user to the application and learn how Kubernetes exposes services.

---

## 1. Learning objectives

You will learn to:

- explain the Kubernetes networking mental model;
- understand Services;
- distinguish ClusterIP, NodePort and LoadBalancer;
- define Ingress;
- define an Ingress Controller;
- configure host-based and path-based routing;
- understand TLS/HTTPS;
- troubleshoot traffic systematically.

---

# 2. Start with the problem

A Kubernetes Pod has an IP address.

But Pods are replaceable.

Today:

~~~text
web Pod → 10.244.1.10
~~~

After a replacement:

~~~text
web Pod → 10.244.1.22
~~~

If users depend directly on Pod IPs, every replacement can break connectivity.

### Definition

A **Service** provides a stable network endpoint for a changing group of Pods.

### Analogy: company phone number

Employees may change desks.

Customers should still call the same company number.

The Service is the company number. Pods are the employees.

---

# 3. Kubernetes traffic model

A common external flow is:

~~~text
Internet
   |
   v
DNS
   |
   v
Load Balancer
   |
   v
Ingress Controller
   |
   v
Ingress rules
   |
   v
Service
   |
   v
Pods
   |
   v
Application
~~~

Not every architecture contains every component, but this model is useful for troubleshooting.

---

# 4. Service

### Definition

A **Service** provides a stable virtual endpoint for a set of Pods.

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

The Service finds Pods using its selector.

~~~text
Service selector
app=foma-web
      |
      v
Pod labels
app=foma-web
~~~

### port vs targetPort

- **port** = port exposed by the Service.
- **targetPort** = port on the selected Pod.

This is a common beginner mistake.

---

# 5. ClusterIP

### Definition

**ClusterIP** provides internal cluster access.

Example:

~~~text
Frontend Pod
     |
     v
API Service
     |
     v
API Pods
~~~

It is the default Service type.

### Analogy

An internal company extension.

People inside the organization can call it without exposing it as a public telephone number.

---

# 6. NodePort

### Definition

**NodePort** exposes a Service through a port on each node.

Conceptually:

~~~text
Node IP : 30080
       |
       v
Service
       |
       v
Pods
~~~

Useful for learning and some simple environments.

### Analogy

A side entrance assigned a known door number.

---

# 7. LoadBalancer

### Definition

A **LoadBalancer Service** requests external load-balancer integration when the platform supports it.

Typical cloud flow:

~~~text
Internet
   |
   v
Cloud Load Balancer
   |
   v
Kubernetes Service
   |
   v
Pods
~~~

### Analogy

A public reception desk that receives visitors and distributes them to available workers.

---

# 8. Ingress

### Definition

An **Ingress** is a Kubernetes API resource that describes HTTP/HTTPS routing rules.

For example:

~~~text
web.foma.local
      |
      v
web-service

api.foma.local
      |
      v
api-service
~~~

Or:

~~~text
foma.local/
      |
      v
web-service

foma.local/api
      |
      v
api-service
~~~

### Critical distinction

**Ingress describes the rules.**

It does not, by itself, implement the traffic-routing software.

---

# 9. Ingress Controller

### Definition

An **Ingress Controller** is software that watches Ingress resources and implements their routing behavior.

Examples include NGINX-based, HAProxy-based, Traefik-based and cloud-provider controllers.

The relationship is:

~~~text
Ingress
"Send /api to api-service"
       |
       v
Ingress Controller
       |
       v
Actual traffic routing
~~~

### Analogy: traffic police

The Ingress is the traffic plan.

The Controller is the traffic system that actually directs the cars.

---

# 10. Host-based routing

### Definition

**Host-based routing** selects a backend based on the hostname.

Example:

~~~text
web.foma.local   → web-service
api.foma.local   → api-service
admin.foma.local → admin-service
~~~

Example:

~~~yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: foma-ingress
spec:
  ingressClassName: nginx
  rules:
    - host: web.foma.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: web-service
                port:
                  number: 80
~~~

### Analogy

An office building has:

~~~text
sales.example.com
support.example.com
hr.example.com
~~~

The hostname tells the routing system which department should receive the request.

---

# 11. Path-based routing

### Definition

**Path-based routing** selects a backend based on the URL path.

Example:

~~~text
foma.local/       → web-service
foma.local/api    → api-service
foma.local/admin  → admin-service
~~~

Example:

~~~yaml
rules:
  - host: foma.local
    http:
      paths:
        - path: /
          pathType: Prefix
          backend:
            service:
              name: web-service
              port:
                number: 80
        - path: /api
          pathType: Prefix
          backend:
            service:
              name: api-service
              port:
                number: 8080
~~~

Do not assume path rewriting happens automatically. It depends on the controller and configuration.

---

# 12. TLS and HTTPS

### Definition

**TLS** protects traffic in transit and allows a client to verify the identity represented by the certificate.

A common Ingress configuration references a TLS Secret:

~~~yaml
spec:
  tls:
    - hosts:
        - foma.life
      secretName: foma-tls
~~~

Development example:

~~~bash
kubectl create secret tls foma-tls \
  --cert=tls.crt \
  --key=tls.key \
  -n production
~~~

### Analogy: sealed envelope

HTTP is like a postcard.

HTTPS is like a sealed envelope: the contents are protected while traveling across the network.

Production environments commonly automate certificate issuance and renewal.

---

# 13. DNS

### Definition

**DNS** translates a human-friendly hostname into an address used to reach a system.

Example:

~~~text
api.foma.life
      |
      v
DNS
      |
      v
Load Balancer / Ingress address
~~~

A perfectly configured Ingress cannot fix DNS pointing to the wrong system.

Therefore DNS belongs in the troubleshooting path.

---

# 14. Install an NGINX Ingress Controller

A common Helm installation is:

~~~bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace
~~~

Verify:

~~~bash
kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx
~~~

Installation details vary by Minikube, Docker Desktop, cloud and bare-metal environments.

---

# 15. Troubleshooting: follow the request

When traffic fails, trace the path instead of randomly changing manifests.

~~~text
DNS
 |
 v
Load Balancer
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
 |
 v
Application
~~~

Check each layer.

### Ingress

~~~bash
kubectl get ingress -A
kubectl describe ingress foma-ingress -n production
~~~

### Controller

~~~bash
kubectl get pods -n ingress-nginx
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller
~~~

### Service

~~~bash
kubectl get svc -n production
kubectl describe svc foma-web -n production
~~~

### Endpoints

~~~bash
kubectl get endpoints -n production
~~~

### Pods

~~~bash
kubectl get pods -o wide -n production
kubectl describe pod <pod> -n production
kubectl logs <pod> -n production
~~~

---

# 16. Common failures

### Ingress exists but traffic does not arrive

Check:

- DNS;
- external address;
- Ingress Controller;
- IngressClass.

### Ingress returns 404

Check:

- hostname;
- path;
- pathType;
- matching rule;
- controller logs.

### Ingress returns 502/503

Check:

- Service name;
- Service port;
- targetPort;
- endpoints;
- Pod readiness;
- application health.

### TLS fails

Check:

- Secret exists;
- Secret is in the correct namespace;
- hostname matches certificate;
- certificate is valid;
- Ingress references the correct Secret.

---

# 17. Hands-on lab

Build:

~~~text
Client
  |
  v
Ingress
  |
  +---- web-service → web Pods
  |
  +---- api-service → API Pods
~~~

Tasks:

1. deploy a web application;
2. create a ClusterIP Service;
3. install an NGINX Ingress Controller;
4. create host-based routing;
5. create path-based routing;
6. test the routes;
7. add development TLS;
8. inspect controller logs;
9. intentionally break a Service selector;
10. diagnose the missing endpoints;
11. restore the selector.

---

# 18. Production best practices

- Use HTTPS for external applications.
- Use a maintained Ingress Controller.
- Keep routing resources in Git.
- Use clear hostnames and paths.
- Avoid exposing internal Services unnecessarily.
- Monitor controller health.
- Automate certificate renewal.
- Validate DNS separately.
- Test routes after changes.
- Consider Gateway API for new platform designs where appropriate.

---

# 19. Knowledge check

1. Why can Pod IPs change?
2. What problem does a Service solve?
3. What is ClusterIP?
4. What is NodePort?
5. What is LoadBalancer?
6. What is an Ingress?
7. What is an Ingress Controller?
8. What is host-based routing?
9. What is path-based routing?
10. What does TLS provide?
11. Where is an Ingress TLS certificate commonly referenced?
12. Why is DNS part of troubleshooting?
13. What should you check if a Service has no endpoints?
14. What should you check for a 502/503?
15. Does an Ingress resource itself implement routing?

### Answers

1. Pods are replaceable.
2. A stable endpoint for changing Pods.
3. Internal Service exposure.
4. Service exposure through node ports.
5. External load-balancer integration where supported.
6. HTTP/HTTPS routing rules.
7. Software implementing those rules.
8. Routing by hostname.
9. Routing by URL path.
10. Protection of traffic in transit and certificate-based identity.
11. A Kubernetes Secret.
12. Users reach applications through DNS names.
13. Selector, labels, readiness and namespace.
14. Service, targetPort, endpoints, readiness and controller logs.
15. No. The controller implements the behavior.

---

# 20. Day 14 challenge

Create:

~~~text
foma.local/
     |
     +---- web-service
     |
     +---- /api → api-service
~~~

Then configure TLS, test both routes, intentionally break the Service selector, diagnose the failure using the traffic-path method, and restore the application.

### FOMA takeaway

> **Kubernetes networking becomes much easier when you trace one request from DNS → load balancer/controller → Ingress → Service → endpoints → Pod → application.**

**Learn • Practice • Build • Troubleshoot • Advance**

https://foma.life
