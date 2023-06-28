#!/bin/bash
set -oe errexit

if ! command -v kind &> /dev/null
then
    echo "kind could not be found"
    exit
fi

if ! command -v helm &> /dev/null
then
    echo "helm could not be found"
    exit
fi

if ! command -v kubectl &> /dev/null
then
    echo "kubectl could not be found"
    exit
fi

# desired cluster name; default is "kind"
echo "creating kind cluster"

kind create cluster --config ./kind-kube/kind-ingress.config

echo "> waiting for kubernetes node(s) become ready"
kubectl wait --for=condition=ready node --all --timeout=60s

echo "deploy contour"
kubectl apply -f ./kind-kube/contour.yaml

echo "create spicedb namespace"
kubectl create namespace spicedb
echo "deploy postgres"
kubectl apply -f ./postgres/secret.yaml -n spicedb
kubectl apply -f ./postgres/storage.yaml -n spicedb
kubectl apply -f ./postgres/postgresql.yaml -n spicedb

echo "deploy spicedb"
kubectl apply -f ./spicedb/secret-datastore.yaml -n spicedb
kubectl apply -f ./spicedb/secret-preshared.yaml -n spicedb
kubectl apply -f ./spicedb/spicedb.yaml -n spicedb

while [[ -z $(kubectl get deployments.apps -n spicedb spicedb -o jsonpath="{.status.readyReplicas}" 2>/dev/null) ]]; do
  echo "still waiting for spicedb"
  sleep 1
done
echo "spicedb is ready"

kubectl get ingresses.networking.k8s.io -n spicedb

echo "Install kube prometheus"
helm install --wait --timeout 15m \
 --namespace monitoring --create-namespace \
 --repo https://prometheus-community.github.io/helm-charts \
 kube-prometheus-stack kube-prometheus-stack


kubectl wait --for=condition=ready --namespace monitoring pods -l "release=kube-prometheus-stack"

echo "Setup service monitor for spicedb"
kubectl apply -f ./prom/sm-spicedb.yaml -n monitoring

kubectl apply -f ./prom/prom-ing.yaml -n monitoring
kubectl apply -f ./prom/grafana-ing.yaml -n monitoring

echo "spicedb endpoints"
kubectl get ingresses.networking.k8s.io -n spicedb
echo "grafana and promethues"
kubectl get ingresses.networking.k8s.io -n monitoring