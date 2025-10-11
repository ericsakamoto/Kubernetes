helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install ksm prometheus-community/kube-state-metrics -n "default"
helm install nodeexporter prometheus-community/prometheus-node-exporter -n "default"