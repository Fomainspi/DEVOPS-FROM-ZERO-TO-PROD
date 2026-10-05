# Day 17 Troubleshooting Lab

Create the namespace first if needed, then apply the failures:

```bash
kubectl create namespace production --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f broken-deployment.yaml
kubectl apply -f broken-service.yaml
kubectl apply -f crash-pod.yaml
```

Investigate:

```bash
kubectl get pods -n production
kubectl describe pod -n production <pod>
kubectl logs -n production <pod>
kubectl logs -n production <pod> --previous
kubectl get events -n production --sort-by=.lastTimestamp
kubectl get endpoints broken-web -n production
```

Do not fix anything until you can state the likely root cause.
