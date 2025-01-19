# First 15 for Kubernetes

## Table of contents <!-- omit from toc -->
- [First 15 for Kubernetes](#first-15-for-kubernetes)
    - [Cluster Analysis](#cluster-analysis)
  - [Checking Kubernetes components for possible backdoors](#checking-kubernetes-components-for-possible-backdoors)
  - [Resources](#resources)


### Cluster Analysis

1. Deploy **kube-bench** or **kubescape** to analyze the cluster since we know the cluster will be compromised (Kubescape preferred).
   
2. Check/replace Kubelet because of the possible backdoor.
   ```bash
   kubectl get all -A -o wide
   ```

3. Check the CNI (Flannel vs Calico) to see if it supports network policies.

4. Find privileged pods and determine if we can make them rootless to reduce attack surface area.
   
5. Make sure encryption at rest is set up for secrets.
   - Check the API server for `--encryption-provider-config`.

## Checking Kubernetes components for possible backdoors
- Kubectl
   1. Identify what version kubectl is:
     ```bash
     kubectl version
     ```
   2. Retrieve the checksum for the binary of that version, and run the checksum between them. If it fails, download the official one:
     ```bash
     echo "$(curl -L \"https://dl.k8s.io/release/v1.31.1/bin/linux/amd64/kubectl.sha256\") $(which kubectl)" | sha256sum --check
     ```

- Kubelet
   1. Validate the version and integrity of the Kubelet binary.

- Kubeadm
   1. Validate the version and integrity of the Kubeadm binary.

Kubescape vs Kube-bench

- Kubescape seems to give better real-time analysis while kube-bench helps with CIS compliance.
- Kubescape helps with fixes and is able to scan specific pods and their images.

## Resources

- Kubescape Documentation 
  - https://github.com/kubescape/kubescape
- Kube-bench Remediations
  - https://medined.github.io/kubernetes/kubebench/ansible/kubebench-remediations/?utm_source=chatgpt.com#1-master
