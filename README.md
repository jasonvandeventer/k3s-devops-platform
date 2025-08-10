# k3s DevOps Platform (Homelab →  Portfolio)

**Status:** Day 1 complete - single-node k3s up, demo app deployed.

## What's here
- 'manifests/' - raw Kubernets YAML (demo nginx)
- 'scripts/' - helper scripts (bootstrap, verify)
- 'docs/TUTORIAL.md'  - day-by-day build notes

## Quick start
```bash
make verify
kubectl apply -f manifests/demo-nginx.yaml
```
