# Automated Canary Releases with Prometheus and Argo CD

- [Automated Canary Releases with Prometheus and Argo CD](#automated-canary-releases-with-prometheus-and-argo-cd)
- [Prerequisites](#prerequisites)
- [Step 1: Install Argo Rollouts (If Not Already Present)](#step-1-install-argo-rollouts-if-not-already-present)
    - [Commands](#commands)
- [Step 2: Create a Canary Rollout Manifest](#step-2-create-a-canary-rollout-manifest)
- [Step 3: Sync the Canary Rollout via Argo CD](#step-3-sync-the-canary-rollout-via-argo-cd)
- [Step 4: Monitor the Canary Rollout](#step-4-monitor-the-canary-rollout)
- [Step 5: Security Considerations](#step-5-security-considerations)
  - [Putting It All Together](#putting-it-all-together)



This guide walks you through setting up a **canary deployment strategy** using **Argo CD** and **Prometheus**. A canary deployment gradually rolls out new versions of an application to a small subset of users before rolling it out to the entire environment. If the new version meets the success criteria (as measured by Prometheus metrics), the rollout continues. If not, it automatically rolls back.


---

# Prerequisites

1. **Kubernetes Cluster**  
   - You have access to a running Kubernetes cluster (version 1.18+ recommended).
   - `kubectl` is configured to communicate with that cluster.

2. **Argo CD Installed**  
   - Argo CD is already installed and running in the cluster.  
   - You have Argo CD CLI access or UI access to manage applications.

3. **Prometheus Installed**  
   - Prometheus is running in the cluster to collect metrics (e.g., from a Helm chart or another method).
   - You can access Prometheus at something like `http://prometheus-server.monitoring:9090`.

4. **Basic GitOps Workflow**  
   - You have a Git repository storing your Kubernetes manifests.
   - Argo CD is pointed at that Git repository to deploy changes automatically.

5. **Familiarity with YAML**  
   - You can edit and commit YAML files to your Git repository.

---

# Step 1: Install Argo Rollouts (If Not Already Present)

Argo Rollouts is a Kubernetes controller and set of CRDs (Custom Resource Definitions) that let you perform advanced deployment strategies such as canary, blue-green, or progressive delivery.

### Commands

```bash
# Create a dedicated namespace for Argo Rollouts (optional but recommended)
kubectl create namespace argo-rollouts

# Apply the Argo Rollouts installation manifest from the official GitHub
kubectl apply -n argo-rollouts -f https://raw.githubusercontent.com/argoproj/argo-rollouts/stable/manifests/install.yaml
```

**Verification**:
- Run `kubectl get pods -n argo-rollouts` and check if the Argo Rollouts controller pod is up and running.
- Run `kubectl get crds | grep rollout` to confirm the new custom resource definitions (e.g., `rollouts.argoproj.io`).


---
# Step 2: Create a Canary Rollout Manifest

A “Rollout” resource (provided by Argo Rollouts) is similar to a standard Kubernetes `Deployment` but supports canary strategies. Below is an **example** manifest where we set up:

- **5 steps** in total:
    1. **SetWeight: 20%** – route 20% of traffic to the new version
    2. **Pause: 60s** – wait 60 seconds, gather performance/error data
    3. **SetWeight: 50%** – route 50% of traffic
    4. **Pause: 60s** – wait again to verify
    5. **SetWeight: 100%** – if success, send all traffic to the new version
- An **analysis** block that references **Prometheus** to check a success rate metric. If the success rate is below `95%`, the rollout fails and automatically rolls back.
    

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: ecommerce-frontend
  namespace: ecommerce
spec:
  replicas: 3
  selector:
    matchLabels:
      app: ecommerce-frontend
  template:
    metadata:
      labels:
        app: ecommerce-frontend
    spec:
      containers:
      - name: ecommerce-frontend
        image: registry.mycompany.com/ecommerce-frontend:1.2  # <-- new version
        ports:
        - containerPort: 80
  strategy:
    canary:
      steps:
      - setWeight: 20
      - pause: { duration: 60 }   # Pause for 60 seconds
      - setWeight: 50
      - pause: { duration: 60 }   # Pause for 60 seconds
      - setWeight: 100
      analysis:
        templates:
          - name: success-rate-check
            successCondition: result >= 95
            metrics:
              - name: success-rate
                interval: 30s
                successCondition: result >= 0.95
                provider:
                  prometheus:
                    address: http://prometheus-server.monitoring:9090
                    query: |
                      sum(rate(http_requests_total{status=~"2xx"}[1m])) 
                      / sum(rate(http_requests_total[1m])) * 100
```
Apply the 
kubectl apply -f <filename>

**Key Points**:
- `image: registry.mycompany.com/ecommerce-frontend:1.2` – This is the **new** version to be tested.
- `steps: - setWeight: 20 ... - setWeight: 50 ...` – Gradually increases how much traffic goes to the new version.
- `analysis.templates[0].metrics[0].provider.prometheus.query` – Prometheus **query** that calculates the percentage of successful HTTP requests (2xx) over total requests in the last minute.
- `successCondition: result >= 95` – If success rate is less than **95%**, the deployment aborts or rolls back.
---

# Step 3: Sync the Canary Rollout via Argo CD

1. **Add the Rollout manifest to your Git repository** (where Argo CD watches for changes):
    - For example, place the file as `rollouts/ecommerce-frontend-canary.yaml` in your repo.

1. **Update or Create an Argo CD Application** that points to this file/directory. If you already have an Argo CD App for `ecommerce`, just make sure this new file is included in your manifests.

2. **Commit and Push** your changes to the main branch (or the branch Argo CD is configured to track).

3. **Argo CD Synchronization**:
    - If Argo CD is set to **auto-sync**, it will detect changes and deploy them.
    - Otherwise, manually trigger a sync through:
        `argocd app sync ecommerce`
        or via the **Argo CD UI**.

----
# Step 4: Monitor the Canary Rollout

1. **Argo CD UI**
    - In the UI, watch the “Rollout” resource within the `ecommerce` namespace.
    - You should see the rollout progress from 20% -> pause -> 50% -> pause -> 100%.

1. **Argo Rollouts CLI** (optional)
    - You can install the `kubectl argo rollouts` plugin to monitor the canary step by step:
```yaml
kubectl argo rollouts get rollout ecommerce-frontend -n ecommerce kubectl argo rollouts status ecommerce-frontend -n ecommerce
```

3. **Prometheus Metrics**
    - The analysis steps rely on the `success-rate` metric. You can view Prometheus directly:
        - Navigate to `http://prometheus-server.monitoring:9090` (or whatever your address is).
        - Run the query manually to confirm data:
```yaml
sum(rate(http_requests_total{status=~"2xx"}[1m])) / sum(rate(http_requests_total[1m])) * 100
```

- If this value drops below 95 for longer than the analysis interval, the rollout will fail.

1. **Automatic Rollback**
    - If the `successCondition` is not met, Argo Rollouts will **abort** or **rollback** the deployment.
    - If successful, it proceeds until 100% of traffic is served by the new version.

---
# Step 5: Security Considerations
1. **Minimal RBAC for Argo Rollouts**
    
    - Only grant necessary permissions to create/edit `Rollout` objects in the cluster.
    - Restrict who can modify the Argo CD application that references the canary.
2. **Validate Metrics Integrity**
    
    - Make sure the Prometheus endpoint is secured or restricted.
    - If an attacker can send bogus metrics, they could trick the canary into staying at a lower weight or force a rollback.
3. **Network Policies**
    
    - Use Kubernetes NetworkPolicy to ensure only the canary pods and your normal traffic can reach each other.
    - Limit external access to internal application metrics.
4. **Secure Ingress**
    
    - If your e-commerce frontend is publicly accessible, ensure TLS termination and properly configured ingress controllers.



## Putting It All Together
1. **Install the Argo Rollouts controller** (Step 1).
2. **Create a Rollout manifest** that defines your canary strategy and references **Prometheus** for metric analysis (Step 2).
3. **Add or Update your Argo CD Application** to include the Rollout manifest, then commit and push changes (Step 3).
4. **Monitor the progress** of your canary rollout in the Argo CD UI or using the `kubectl argo rollouts` plugin (Step 4).
5. **Ensure security best practices** by limiting RBAC privileges, validating traffic, and securing your metrics endpoints (Step 5).