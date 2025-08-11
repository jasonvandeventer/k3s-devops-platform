# K3s DevOps Platform (Homelab → Portfolio)

**Status:** Day 3 complete ✅ 
- k3s single-node on Proxmox
- Longhorn installed and **default** StorageClass
- Argo CD up, GitOps app synced
- Traefik Ingress working at **http://dev.demo.local/**

**Next:** Day 4 – CI runner + pipeline that bumps image tags in the GitOps overlay → Argo auto-deploys.

---

## Why this project
Build a production-style GitOps platform on k3s that recruiters can grok in 60 seconds:
- Lightweight Kubernetes (k3s) on Proxmox
- Clear repo structure + Make targets
- Real deployments, storage, CI/CD, and observability by the end

---

## Current architecture (Day 3)

- **Node (LAN):** `10.42.1.60`
- **k3s Pod CIDR:** `10.240.0.0/16`
- **k3s Service CIDR:** `10.241.0.0/16`
- **Ingress Controller:** Traefik (bundled with k3s)
- **Storage:** Longhorn (**default** StorageClass; replicas=1 for single node)
- **GitOs:** Argo CD (automated sync + self-heal)
- **App:** `demo-nginx` (Kustomize base + `dev` overlay, Ingress `dev.demo.local`)

```mermaid
flowchart LR
  dev[Developer laptop] -->|git push| gh[(GitHub repo)]
  gh -->|Argo watches<br/>gitops/.../overlays/dev| argo[Argo CD<br/>(argocd ns)]
  argo -->|applies| k3s[(k3s API server)]

  k3s --> deploy[Deployment: dev-demo-nginx]
  deploy --> pods[Pods: nginx (replicas)]
  k3s --> svc[Service: dev-demo-nginx:80 (ClusterIP)]

  ing[Traefik Ingress Controller] -->|Host: dev.demo.local| svc

  k3s --> sc[StorageClass: longhorn (default)]
  sc --> pvc[PVC/PV: Longhorn volume]

sequencDiagram
  participant Client
  participant Traefik
  participant Service
  participant Pod
  Client->>Traefik: HTTP GET dev.demo.local/
  Traefik->>Service: ClusterIP :80
  Service->>Pod: containerPort :80
  Pod-->>Client: 200 OK (nginx)
```

> Note: k3s defaults to `10.42.0.0/16` for Pods, which **conflicted with my LAN (10.42.1.0/24)**. I reinstalled k3s with non-overlapping ranges above. Do this early or routing gets weird.

`/etc/rancher/k3s/config.yaml` (on the node):
```yaml
node-name: k3s-core-1
node-ip: 10.42.1.60
write-kubeconfig-mode: "0644"
tls-san:
  - 10.42.1.60
  - k3s-core-1
cluster-cidr: 10.240.0.0/16
service-cidr: 10.241.0.0/16
cluster-dns: 10.241.0.10
