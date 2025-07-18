helm install prometheus prometheus-community/prometheus -n monitoring -f prometheus-values.yaml
helm install grafana grafana/grafana -n monitoring -f grafana-values.yaml

kubectl port-forward svc/prometheus-server 9090:80 -n monitoring
kubectl port-forward svc/grafana 3000:80 -n monitoring