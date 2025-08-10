# K3s DevOps Platform (Homelab → Portfolio)

**Status:** Day 1 complete ✅ — single-node k3s up on Proxmox, demo app deployed and reachable.  
**Next:** Day 2 – install Longhorn and verify persistent volumes.

---

## Why this project
Build a production-style GitOps platform on k3s that recruiters can grok in 60 seconds:
- Lightweight Kubernetes (k3s) on Proxmox
- Clear repo structure + Make targets
- Real deployments, storage, CI/CD, and observability by the end

---

## Current architecture (Day 1)

- **Node (LAN):** `10.42.1.60`
- **k3s Pod CIDR:** `10.240.0.0/16`
- **k3s Service CIDR:** `10.241.0.0/16`
- **Ingress:** Traefik (installed by k3s, not configured yet)
- **Demo app:** `nginx` (Deployment + Service)

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
