# Setting up a local Ingress resource for a k8 pod

# 1. Assumption that pod is currently up and running
Get cluster svc port
	`sudo kubectl get svc -n <namespace>`

*If their is no svc for your pod; see step 2.*
## 2. Create a Service to Expose the Pod Internally (Dependent)

1. **Create a Service** of type `ClusterIP` (the default) or `NodePort` if needed.
    
2. The Service _selects_ the Pod using labels. For example, if your Pod’s labels are `app: my-app`, your Service might look like:

```yaml
apiVersion:  networking.k8s.io/v1
kind: Service
metadata:
  name: my-service
  labels:
    app: my-app
spec:
  selector:
    app: my-app
  ports:
    - port: 80         # Port on the Service
      targetPort: 8080 # The port on the Pod container

```


### Apply the service file
`kubectl apply -f  <service-file>.yaml`

3. Confirm the Service is created and has an internal cluster IP:
```sh
    kubectl get svc   
````

The listed  svc port should be  the same as the port in the file

| **Why a Service?** An Ingress resource references a Service, _not_ directly a Pod. The Service is the stable endpoint that can load-balance across multiple Pod replicas.

*Helm may have created the service automatically.*


# 3. Install (or Verify) an Ingress Controller

- Kubernetes **doesn’t** automatically ship with an Ingress controller. You need to install one. Common options include:
    - **NGINX Ingress Controller**
    - **Traefik**
    - **HAProxy**
    - **Kong**
    - **Istio** (if you’re using a service mesh)

Example of installing the **NGINX Ingress Controller** via Helm: 

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install my-nginx ingress-nginx/ingress-nginx

```

or by using the official yaml config
```sh
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-vX.Y.Z/deploy/static/provider/cloud/deploy.yaml

```



# 4. Create ingress Resource for the service & pod

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-app-ingress
  # If using the NGINX Ingress Controller:
  annotations:
    kubernetes.io/ingress.class: "nginx"
spec:
  rules:
    - host: myapp.local # DNS name or /etc/hosts name any name
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: my-service   # Must match the Service name
                port:
                  number: 80       # Must match the Service 'port'

```

- `host: myapp.local # DNS name or /etc/hosts name`
/etc/hosts  will map a url name to the ip of the machine

- `host: myapp.local` is a placeholder; you can use a real domain, or for local dev, add an entry in `/etc/hosts`.

`node.ip myapp.local`

**Apply it**
`kubectl apply -f my-ingress.yaml`

# 5. Confirm the Ingress Is Active

Check the Ingress status:

`kubectl get ingress -n <namespace>`



# 6. Test access

`curl http://myapp.local/`


## Summary

1. **Deploy Your Pod / Deployment**
2. **Create a Service** to expose the Pod _internally_ (ClusterIP or NodePort).
3. **Install an Ingress Controller** in your cluster.
4. **Create an Ingress Resource** that references your Service (and sets up the hostname/path).
5. **Configure DNS or local hosts file** to point your domain to the Ingress Controller’s external IP.
6. **Verify** you can reach the application from outside the cluster.