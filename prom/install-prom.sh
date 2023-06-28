helm install --wait --timeout 15m \
 --namespace monitoring --create-namespace \
 --repo https://prometheus-community.github.io/helm-charts \
 kube-prometheus-stack kube-prometheus-stack