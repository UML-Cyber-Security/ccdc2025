# Argo CD Pipeline update

- [Argo CD Pipeline update](#argo-cd-pipeline-update)
  - [Argo CD Pipeline Update for Critical Security Patch](#argo-cd-pipeline-update-for-critical-security-patch)
    - [Technical Steps](#technical-steps)



## Argo CD Pipeline Update for Critical Security Patch
Goal: If yo need to **update your Argo CD-managed apps** in the existing cluster to use the patched image.

### Technical Steps
1. **Patch the Container Image**
    - Find  the updated container image
    - ex:
	    - Security/DevOps publishes a new version, e.g. `registry.company.com/my-service:1.1-patch`.

2. **Update Git Repository**
    - In your repository’s K8s manifests 
```yaml
containers:
  - name: my-service
    image: registry.company.com/my-service:1.1-patch

```

- Commit and push to `main` or your designated branch.
3. **Argo CD Sync**
    - If Argo CD is configured for **automated sync**, it will detect and deploy the new version automatically.
    - If manual sync is required, log into the Argo CD UI or CLI:
        `argocd app sync my-app`

4. **Verify Deployment**
    - Check new pods running the patched image:
`kubectl get pods -n my-app-namespace -o wide

5. **Security Considerations**
- Run a vulnerability scan on the new image before deploying.
- Keep an emergency rollback plan if the patched image introduces unexpected behavior.
