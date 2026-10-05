# Day 14 — Kubernetes Ingress & Networking

> FOMA · William Foma · Expose, secure and manage access to applications

## 1. Networking mental model

Typical request flow:

**Internet → Ingress Controller → Ingress rules → Service → Pods**

An **Ingress** resource describes HTTP/HTTPS routing rules. An **Ingress Controller** is the software that implements those rules.

Ingress itself is not a load-balancer implementation.

## 2. Services recap

| Type | Typical use |
|---|---|
| ClusterIP | Internal application traffic |
| NodePort | Development/testing external access |
| LoadBalancer | External access through cloud integration |

Inspect services and endpoints:

~~~bash
kubectl get svc -A
kubectl get endpoints -n production
kubectl describe svc foma-app -n production
~~~

If a Service has no endpoints, compare its selector with Pod labels.

## 3. Install NGINX Ingress Controller

A common Helm workflow is:

~~~bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx   --namespace ingress-nginx   --create-namespace
~~~

Verify:

~~~bash
kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx
~~~

Installation details can vary by distribution and cloud provider.

## 4. Host-based routing

~~~yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: foma-ingress
  namespace: production
spec:
  ingressClassName: nginx
  rules:
    - host: foma.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: foma-app
                port:
                  number: 80
~~~

The hostname determines which rule is selected.

## 5. Path-based routing

One hostname can route to multiple Services:

~~~yaml
rules:
  - host: foma.local
    http:
      paths:
        - path: /
          pathType: Prefix
          backend:
            service:
              name: web-app
              port:
                number: 80
        - path: /api
          pathType: Prefix
          backend:
            service:
              name: api
              port:
                number: 8080
~~~

Understand path rewriting behavior for your chosen controller.

## 6. TLS/HTTPS

TLS normally references a Kubernetes Secret:

~~~yaml
spec:
  tls:
    - hosts:
        - foma.life
      secretName: foma-tls
~~~

Create a development TLS Secret:

~~~bash
kubectl create secret tls foma-tls --cert=tls.crt --key=tls.key -n production
~~~

For production, certificate automation such as cert-manager can reduce manual renewal work.

## 7. Troubleshooting

~~~bash
kubectl get ingress -A
kubectl get svc -n production
kubectl get endpoints -n production
kubectl describe ingress foma-ingress -n production
kubectl get pods -n ingress-nginx
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller
~~~

Common causes:
- incorrect IngressClass;
- wrong Service name or port;
- no Service endpoints;
- DNS pointing to the wrong address;
- missing TLS Secret;
- controller not running.

Test after DNS/host configuration:

~~~bash
curl -H 'Host: foma.local' http://<INGRESS-IP>/
~~~

## 8. Hands-on practice

1. Deploy a web application.
2. Create a ClusterIP Service.
3. Install an NGINX Ingress Controller.
4. Create host-based routing.
5. Add a second Service and path-based routing.
6. Configure development TLS.
7. Test the routes.
8. Inspect controller logs.
9. Break one routing rule intentionally.
10. Troubleshoot without deleting the namespace.

## 9. Production best practices

- Use TLS for external traffic.
- Use a maintained Ingress Controller.
- Keep routing resources in Git.
- Use clear hostnames and paths.
- Avoid exposing internal Services unnecessarily.
- Monitor controller health and traffic.
- Automate certificate renewal.
- Validate routing after changes.
- Consider Gateway API for new platform designs where appropriate.

## Knowledge check

1. Ingress versus Ingress Controller?
2. What is ClusterIP for?
3. What is host-based routing?
4. What is path-based routing?
5. Where is TLS data normally stored?
6. What should you inspect when routing fails?
7. Why can a Service have no endpoints?
8. Which component implements Ingress behavior?

**Answers:** Ingress describes rules while the controller implements them; ClusterIP provides internal access; host routing uses the hostname; path routing uses the URL path; TLS commonly uses a Secret; inspect Ingress, controller, Service, endpoints, DNS and ports; selector/label mismatch can produce no endpoints; the Ingress Controller implements behavior.

## FOMA takeaway

**Good Kubernetes networking turns many internal applications into a controlled and secure entry point.**

Learn • Practice • Build • Advance  
https://foma.life
