## Prometheus – InfluxDB Integration for Historical Metrics Analysis

- [Prometheus – InfluxDB Integration for Historical Metrics Analysis](#prometheus--influxdb-integration-for-historical-metrics-analysis)
  - [Technical Steps](#technical-steps)


**Example Business Scenario & Requirement**  
Prometheus is configured for short-term retention, and InfluxDB is used for extended historical analysis. You need to configure Prometheus to **remote-write** to InfluxDB so that you can query older data via InfluxQL or Flux.


### Technical Steps
1. **Ensure InfluxDB and Prometheus are Running in the Cluster**
    - Verify pods and services for each:
	    `kubectl get pods -n influxdb kubectl get pods -n monitoring`
	    
2. **Add Remote Write Config**
    - Edit Prometheus config (via Helm values or a ConfigMap if you’re using the official chart).
    - In the Helm chart, you can set something like:
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: grafana
  namespace: monitoring
  annotations:
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    nginx.ingress.kubernetes.io/auth-type: basic
    nginx.ingress.kubernetes.io/auth-secret: grafana-auth
spec:
  tls:
  - hosts:
    - grafana.example.com
    secretName: grafana-tls
  rules:
  - host: grafana.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: grafana
            port:
              number: 80

```

- Adjust host, port, and credentials to match your InfluxDB deployment.

3. **Restart or Redeploy Prometheus**    
	1. Upgrade  using Helm
```yaml
helm upgrade prom prometheus-community/prometheus \
  --namespace monitoring \
  -f your-values.yaml

```

4. **Verify Data Flow**
    - Check InfluxDB logs for incoming Prometheus data.
    - Query InfluxDB to see new measurements:
```yaml
influx -host influxdb.influxdb -port 8086 -username admin -password 'SecurePassword'
USE iot_data

SHOW MEASUREMENTS #run inside influxdb cli

```

5. **Security Considerations**
    - Always use TLS if remote writing outside the cluster. Within the cluster, use Network Policies to restrict access.
    - Encrypt secrets storing InfluxDB credentials in Kubernetes.