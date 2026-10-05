# Day 14 Lab

Install an NGINX Ingress Controller according to your cluster platform, then:

~~~bash
kubectl apply -f ingress.yaml
kubectl get ingress -n production
kubectl describe ingress foma-ingress -n production
kubectl get pods -n ingress-nginx
~~~

For local testing, configure foma.local according to your cluster's ingress address. Verify controller logs before troubleshooting application routing.
