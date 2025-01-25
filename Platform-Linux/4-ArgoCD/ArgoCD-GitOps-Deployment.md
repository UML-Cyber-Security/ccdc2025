# Argo CD Deployment for GitOps-based Application Delivery### Technical Steps

- [Argo CD Deployment for GitOps-based Application Delivery### Technical Steps](#argo-cd-deployment-for-gitops-based-application-delivery-technical-steps)
  - [1.  **Create namespace**](#1--create-namespace)
  - [2.  **Install Argo CD**](#2--install-argo-cd)
  - [3.  **Access Argo CD UI**](#3--access-argo-cd-ui)
  - [4.  **Log in as Admin**](#4--log-in-as-admin)
  - [5.  **Create a GitOps Application**](#5--create-a-gitops-application)
  - [6.  **Security Considerations**](#6--security-considerations)


## 1.  **Create namespace**
    1.  bashCopykubectl create namespace argocd
    
## 2.  **Install Argo CD**
    *  ``kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml`
    
    *  `kubectl get pods -n argocd`

## 3.  **Access Argo CD UI**
    *   bashCopykubectl port-forward svc/argocd-server -n argocd 8080:443
    *   Option 2: Create an Ingress for production access with TLS.

## 4.  **Log in as Admin**
    * `kubectl get secret argocd-initial-admin-secret -n argocd -o yaml`
    *   Change the default password via the Argo CD UI or CLI (argocd login).

## 5.  **Create a GitOps Application**
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app
  namespace: argocd
spec:
  destination:
    name: ''
    namespace: my-app-namespace
    server: 'https://kubernetes.default.svc'
  source:
    repoURL: 'https://git.company.com/myorg/my-app.git'
    targetRevision: main
    path: 'k8s'
  project: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

Apply it
    `Copykubectl apply -n argocd -f my-app-argo-application.yaml`

## 6.  **Security Considerations**
    *   Integrate SSO or OAuth for Argo CD logins.
    *   Store Git credentials in Kubernetes Secrets with restricted RBAC.
    *   Limit Argo CD’s privileges; only allow it to manage designated namespaces.