# Day 16 RBAC Lab

Apply in order:

```bash
kubectl apply -f namespace.yaml
kubectl apply -f serviceaccount.yaml
kubectl apply -f role.yaml
kubectl apply -f rolebinding.yaml

kubectl auth can-i get pods --as=system:serviceaccount:production:app-reader -n production
kubectl auth can-i delete pods --as=system:serviceaccount:production:app-reader -n production
kubectl auth can-i get secrets --as=system:serviceaccount:production:app-reader -n production
```

Expected: get Pods = yes; delete Pods = no; get Secrets = no.
