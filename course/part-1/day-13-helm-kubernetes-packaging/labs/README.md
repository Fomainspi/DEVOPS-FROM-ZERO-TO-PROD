# Day 13 Helm Lab

~~~bash
helm create foma-app
cp values-prod.yaml foma-app/values-prod.yaml
helm lint ./foma-app
helm template foma-app ./foma-app -f foma-app/values-prod.yaml
helm install foma-app ./foma-app -n production --create-namespace -f foma-app/values-prod.yaml
helm list -n production
helm upgrade foma-app ./foma-app -n production --set replicaCount=4
helm history foma-app -n production
helm rollback foma-app 1 -n production
~~~

Inspect generated resources with kubectl.
