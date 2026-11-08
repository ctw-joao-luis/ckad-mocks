#!/bin/bash
set -x
exec > /var/log/exam-setup.log 2>&1

until kubectl get nodes >/dev/null 2>&1; do sleep 2; done
kubectl wait --for=condition=Ready node --all --timeout=300s

mkdir -p /exam/q1 /exam/q2 /exam/q3 /exam/q4 /exam/q5 /exam/q6

# Q1: mix of restricted and open namespaces
for ns in andromeda quasar sirius vesta; do
  kubectl create namespace "$ns"
  kubectl label namespace "$ns" tier=restricted
done
for ns in nebula pulsar; do
  kubectl create namespace "$ns"
  kubectl label namespace "$ns" tier=open
done

# Q2: ServiceAccount + quota that forces cpu/memory requests and limits
kubectl -n andromeda create serviceaccount andro-runner
kubectl -n andromeda create quota andro-quota \
  --hard=requests.cpu=200m,requests.memory=128Mi,limits.cpu=400m,limits.memory=256Mi

# Q3: two ServiceAccounts with long-lived token Secrets under unrelated names
kubectl -n andromeda create serviceaccount cosmo-bot
kubectl -n andromeda create serviceaccount nova-bot
kubectl apply -f - <<'EOF'
apiVersion: v1
kind: Secret
metadata:
  name: cb-credentials-x7k2
  namespace: andromeda
  annotations:
    kubernetes.io/service-account.name: cosmo-bot
type: kubernetes.io/service-account-token
---
apiVersion: v1
kind: Secret
metadata:
  name: nb-credentials-p4q9
  namespace: andromeda
  annotations:
    kubernetes.io/service-account.name: nova-bot
type: kubernetes.io/service-account-token
EOF

# Q4: Deployment referencing a ConfigMap that doesn't exist yet
cat > /exam/q4/index.html <<'EOF'
<html><body><h1>Starlight Observatory</h1><p>status: online</p></body></html>
EOF
kubectl apply -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: starlight
  namespace: nebula
spec:
  replicas: 1
  selector:
    matchLabels:
      app: starlight
  template:
    metadata:
      labels:
        app: starlight
    spec:
      volumes:
      - name: html
        configMap:
          name: starlight-html
      containers:
      - name: web
        image: nginx:1.27-alpine
        volumeMounts:
        - name: html
          mountPath: /usr/share/nginx/html
EOF

# Q5: single Pod to convert into a Deployment
cat > /exam/q5/orbit-pod.yaml <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: orbit-api
  namespace: sirius
  labels:
    app: orbit-api
spec:
  containers:
  - name: api
    image: busybox:1.36
    command: ["sh", "-c", "while true; do echo heartbeat; sleep 10; done"]
EOF
kubectl apply -f /exam/q5/orbit-pod.yaml

# Q6: Pods with non-obvious names
create_pod() {
  kubectl -n vesta run "$1" --image=nginx:1.27-alpine --labels="$2"
}
create_pod vst-a81c "system=ledger,tier=backend"
create_pod vst-3f0d "system=storefront,tier=frontend"
create_pod vst-9b27 "system=storefront,tier=db"
create_pod vst-c45e "system=ledger,tier=db"
create_pod vst-61aa "system=storefront,tier=cache"
create_pod vst-e7d2 "system=reports,tier=backend"

kubectl -n sirius wait --for=condition=Ready pod/orbit-api --timeout=180s
kubectl -n vesta wait --for=condition=Ready pod --all --timeout=180s

touch /tmp/.setup-done
