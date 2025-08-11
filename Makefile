# --- Config ---
KUBECONFIG ?= $(HOME)/.kube/config-k3s-core-1
ARGOCD_NS  ?= argocd
HOST ?= dev.demo.local

# --- Helpers ---
.PHONY: help
help: ## Show available targets
	@grep -E '^[a-zA-Z0-9_-]+:.*?## ' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS=":.*?## "}; {printf "%-18s %s\n", $$1, $$2}'

.PHONY: verify
verify: ## Verify cluster connectivity and show basic health
	KUBECONFIG=$(KUBECONFIG) kubectl cluster-info
	KUBECONFIG=$(KUBECONFIG) kubectl get nodes -o wide
	KUBECONFIG=$(KUBECONFIG) kubectl get pods -A | head -n 40

# --- Day 1 smoke test (kept for convenience) ---
# NOTE: Your GitOps app now manages *dev-demo-nginx*.
# These targets create/remove a separate *demo-nginx* in default ns for ad-hoc testing.
.PHONY: demo-nginx
demo-nginx: ## Apply demo nginx (Deployment+Service) from manifests/
	KUBECONFIG=$(KUBECONFIG) kubectl apply -f manifests/demo-nginx.yaml
	KUBECONFIG=$(KUBECONFIG) kubectl rollout status deployment/demo-nginx -n default

.PHONY: clean-demo
clean-demo: ## Remove the ad-hoc demo nginx resources
	-KUBECONFIG=$(KUBECONFIG) kubectl delete -f manifests/demo-nginx.yaml --ignore-not-found=true

# --- QoL: UIs ---
.PHONY: pf-argocd
pf-argocd: ## Port-forward Argo CD UI to http://localhost:8080
	KUBECONFIG=$(KUBECONFIG) kubectl -n $(ARGOCD_NS) port-forward svc/argocd-server 8080:80

.PHONY: pf-longhorn
pf-longhorn: ## Port-forward Longhorn UI to http://localhost:8081
	KUBECONFIG=$(KUBECONFIG) kubectl -n longhorn-system port-forward svc/longhorn-frontend 8081:80

# --- Demo: quick ingress check ---
.PHONY: demo
demo: ## Curl the ingress host and assert 200 OK (override HOST=... to test others)
	@echo "→ GET http://$(HOST)/"
	@http_code=$$(curl -sS -o /tmp/demo.out -w '%{http_code}' http://$(HOST)/); \
	if [ "$$http_code" = "200" ]; then \
	  echo "✅ $$http_code OK — ingress routing works"; \
	  head -n 5 /tmp/demo.out; \
	else \
	  echo "❌ HTTP $$http_code — check ingress/service/pods"; \
	  cat /tmp/demo.out; exit 1; \
	fi
