# InfluxDB Deployment for IoT Sensor Data

## Create a Namespace** & Directory (organizational purposes)
	Decide on a dedicated namespace (e.g., `influxdb`)
	`mkdir influxdb`
## Deploy influxdb via helm (much quicker than yaml)
- Add the InfluxDB Helm repo and update
```sh
helm repo add influxdata https://helm.influxdata.com/
helm repo update
```
-  Install Influxdb w/ secure defaults
```sh
helm install influxdb influxdata/influxdb \
  --namespace influxdb \
  --set persistence.enabled=true \
  --set adminUser.password="1qazxsW@1" \
  --set config.http.authEnabled=true
```

*Helm should install the service and  pod*

## Verify pods and services
```bash
kubectl get pods -n influxdb
kubectl get svc -n influxdb
```


## Configure TLS and ingress resource
*Only possible if the Nginx ingress Controller is setup*

Create an ingress resouce with TLS termination

```sh
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


## OR Port Forward
- Likely this is much faster for the competition.
```sh
kubectl port-forward svc/influxdb 8086:8086 -n influxdb

influx -host localhost -port 8086 -username admin -password 'SecurePassword'

```



## Create database for IOT data

```sh
kubectl exec -it <influxdb-pod-name> -n <namespace> -- influx -username <admin-username> -password '<admin-password>'

```

```SQL
CREATE DATABASE iot_data
--run inside of thhe container--
```

----
# Using Telegraf to Send Data to InfluxDB

## Install Telegraf
 Install Telegraf on your IoT gateway or server:

  `sudo apt-get update && sudo apt-get install -y telegraf`

## Configure Telegraf for InfluxDB
Edit the Telegraf configuration file `(/etc/telegraf/telegraf.conf)` to include the following settings:

 ```toml
[[outputs.influxdb]]
  urls = ["http://<influxdb-service-ip>:8086"]
  database = "iot_data"
  username = "admin"
  password = "1qazxsW@1"

[[inputs.cpu]]
  percpu = true
  totalcpu = true
  fielddrop = ["time_*"]

[[inputs.mem]]
  fieldpass = ["used_percent"]

 ```

 ## Start Telegraf
 Restart and enable the Telegraf service:

```bash
sudo systemctl restart telegraf
sudo systemctl enable telegraf
```

Telegraf will now collect CPU and memory usage metrics and send them to the iot_data database in InfluxDB.




