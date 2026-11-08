#!/bin/bash
set -x
exec > /var/log/exam-setup.log 2>&1

until kubectl get nodes >/dev/null 2>&1; do sleep 2; done
kubectl wait --for=condition=Ready node --all --timeout=300s

mkdir -p /exam/q1 /exam/q2 /exam/q3 /exam/q4 /exam/q5 /exam/q6
for ns in hydra lumen orbit vault; do kubectl create namespace "$ns"; done

# Ingress controller, exposed on NodePort 30080
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.11.3/deploy/static/provider/baremetal/deploy.yaml
kubectl -n ingress-nginx patch svc ingress-nginx-controller --type=json \
  -p '[{"op":"replace","path":"/spec/ports/0/nodePort","value":30080}]'
echo "172.30.1.2 shop.exam.local" >> /etc/hosts

# Q1
kubectl -n hydra create deployment hydra-web --image=httpd:2.4-alpine
kubectl -n hydra expose deployment hydra-web --name=hydra-svc --port=8080 --target-port=80

# Q2: two backends that answer on any path
for app in catalog checkout; do
  kubectl -n lumen create deployment "$app" --image=hashicorp/http-echo:1.0 -- /http-echo "-text=$app service" -listen=:5678
  kubectl -n lumen expose deployment "$app" --name="$app-svc" --port=80 --target-port=5678
done

# Q3: takes ~20s before nginx listens
kubectl apply -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: slowpoke
  namespace: orbit
spec:
  replicas: 1
  selector:
    matchLabels:
      app: slowpoke
  template:
    metadata:
      labels:
        app: slowpoke
    spec:
      containers:
      - name: web
        image: nginx:1.27-alpine
        command: ["sh", "-c", "sleep 20 && exec nginx -g 'daemon off;'"]
        ports:
        - containerPort: 80
EOF

# Q4: crashing Pod
kubectl apply -f - <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: glitch
  namespace: orbit
spec:
  containers:
  - name: glitch
    image: busybox:1.36
    command: ["sh", "-c", "echo 'starting glitch v2.3'; sleep 5; echo 'FATAL: config /etc/glitch/app.conf not found' >&2; exit 1"]
EOF

# Q5: hostPath directory must exist on every node
mkdir -p /mnt/vault-data
ssh -o StrictHostKeyChecking=no node01 mkdir -p /mnt/vault-data

kubectl -n ingress-nginx wait --for=condition=complete job --all --timeout=300s
kubectl -n ingress-nginx rollout status deploy/ingress-nginx-controller --timeout=300s
kubectl -n hydra rollout status deploy/hydra-web --timeout=180s
kubectl -n lumen rollout status deploy/catalog --timeout=180s
kubectl -n lumen rollout status deploy/checkout --timeout=180s

touch /tmp/.setup-done
