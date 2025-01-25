# Influxdb Resource example

The Ingress resource can be adapted for other technology, such as Prometheus

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: influxdb-ingress
  namespace: influxdb
  annotations:
    kubernetes.io/ingress.class: "nginx" 
    # ^ Tells Kubernetes that this Ingress should be handled by the NGINX Ingress Controller.
spec:
  tls:
    - hosts:
        - influxdb.example.com
      secretName: influxdb-tls
      # ^ This references a TLS secret in the 'influxdb' namespace. 
      #   The secret must contain a valid certificate+key for "influxdb.example.com".
  rules:
    - host: influxdb.example.com
      # ^ Traffic sent to this domain name will match this rule.
      http:
        paths:
          - path: /
            pathType: Prefix
            # ^ pathType: Prefix means any request starting with '/' 
            #   (like /, /query, /write) will be routed to the backend below.
            backend:
              service:
                name: influxdb
                # ^ This is the name of the Service (in the same namespace, 'influxdb') 
                #   that the Ingress routes traffic to.
                port:
                  number: 80
                  # ^ This must match the 'port' you defined in the Service 
                  #   (not necessarily the container’s actual port). 
                  #
                  # Example:
                  #   kind: Service
                  #   spec:
                  #     ports:
                  #       - port: 80         # <-- The Ingress references THIS "port".
                  #         targetPort: 8086 # The actual container port (e.g., InfluxDB).
                  #
                  # The Ingress doesn't need to know the container's port directly; 
                  # it only cares about the Service's "port" definition.

```


### Explanation of Key Parts

1. **`annotations.kubernetes.io/ingress.class: "nginx"`**
    
    - Tells the cluster to use the **NGINX Ingress Controller** to handle this Ingress resource.
    - If you’re using a different controller (e.g., Traefik), you would use the corresponding annotation.
2. **`spec.tls`**
    
    - Lists domain names (`hosts`) for which TLS (HTTPS) should be used and references the **secret** that stores the certificate/key pair.
    - `secretName: influxdb-tls` is a Kubernetes Secret object containing the certificate and private key for `influxdb.example.com`.
    - The secret must be in the **same namespace** as the Ingress.
3. **`spec.rules.host`**
    
    - The hostname (`influxdb.example.com`) that the Ingress Controller will respond to.
    - If the HTTP `Host` header matches `influxdb.example.com`, traffic will be routed according to this rule.
    - Typically, you’d point DNS records for `influxdb.example.com` to the IP or load balancer address of the Ingress Controller.
4. **`paths.path` and `pathType`**
    
    - `"/"` with `pathType: Prefix` means all requests starting with `"/"` (basically all paths) go to this backend.
    - You can route different sub-paths (e.g., `/app`, `/api`) to different Services if needed.
5. **`backend.service.name` and `backend.service.port.number`**
    
    - Specifies the Service that traffic should be forwarded to.
        
    - The port (`80` in this example) must match the **Service**’s **`port`** (not necessarily the **`targetPort`**).
        
    - In a typical InfluxDB setup, your Service might look like:
        
```sh
kind: Service
spec:
  selector:
    app: influxdb
  ports:
    - port: 80         # This is the "port" the Ingress references
      targetPort: 8086 # The actual container port running InfluxDB

```
       
- Even though InfluxDB listens on `8086`, your Service can expose it on `80`, and the Ingress needs to refer to the **Service**’s `port` value (which is `80`)—this is how Kubernetes routing works.