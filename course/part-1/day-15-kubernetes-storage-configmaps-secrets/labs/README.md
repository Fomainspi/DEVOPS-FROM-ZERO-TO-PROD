# Day 15 Lab

The included hostPath PV is for local learning only. Use a StorageClass/cloud storage for production.

~~~bash
kubectl apply -f namespace.yaml
kubectl apply -f pv.yaml
kubectl apply -f pvc.yaml
kubectl apply -f configmap.yaml
kubectl apply -f secret.yaml
kubectl apply -f pod.yaml
kubectl get pv
kubectl get pvc -n production
kubectl get pod -n production
kubectl exec -it foma-app -n production -- sh
~~~

Inside the Pod:
~~~bash
echo "persistent-data" > /var/lib/foma/test.txt
cat /var/lib/foma/test.txt
~~~

Delete and recreate the Pod, then verify the storage behavior.
