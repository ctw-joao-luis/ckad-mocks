#!/bin/bash
set -x
exec > /var/log/exam-setup.log 2>&1

until kubectl get nodes >/dev/null 2>&1; do sleep 2; done
kubectl wait --for=condition=Ready node --all --timeout=300s

mkdir -p /exam/q1 /exam/q2 /exam/q3 /exam/q4/image /exam/q5 /exam/q6

for ns in orion lyra pegasus vega; do kubectl create namespace "$ns"; done

# Q2: Deployment manifest without the InitContainer, not applied yet
cat > /exam/q2/web-init.yaml <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-init
  namespace: orion
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web-init
  template:
    metadata:
      labels:
        app: web-init
    spec:
      volumes:
      - name: content
        emptyDir: {}
      containers:
      - name: nginx
        image: nginx:1.27-alpine
        ports:
        - containerPort: 80
        volumeMounts:
        - name: content
          mountPath: /usr/share/nginx/html
EOF

# Q3: app + classic sidecar; images pre-pulled so pullPolicy Never works on any node
crictl pull docker.io/library/busybox:1.36
ssh -o StrictHostKeyChecking=no node01 crictl pull docker.io/library/busybox:1.36
kubectl apply -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: collector
  namespace: lyra
spec:
  replicas: 2
  selector:
    matchLabels:
      app: collector
  template:
    metadata:
      labels:
        app: collector
    spec:
      volumes:
      - name: logs
        emptyDir: {}
      containers:
      - name: app
        image: nginx:1.27-alpine
        imagePullPolicy: Always
        volumeMounts:
        - name: logs
          mountPath: /var/log/nginx
      - name: log-shipper
        image: busybox:1.36
        command: ["sh", "-c", "touch /logs/access.log; tail -F /logs/access.log"]
        volumeMounts:
        - name: logs
          mountPath: /logs
EOF

# Q4: podman + local registry
if ! command -v podman >/dev/null; then
  apt-get update
  DEBIAN_FRONTEND=noninteractive apt-get install -y podman
fi
echo "127.0.0.1 registry.exam.local" >> /etc/hosts
mkdir -p /etc/containers/registries.conf.d
cat > /etc/containers/registries.conf.d/exam.conf <<'EOF'
[[registry]]
location = "registry.exam.local:5000"
insecure = true
EOF
podman run -d --name registry --restart always -p 5000:5000 docker.io/library/registry:2

cat > /exam/q4/image/app.sh <<'EOF'
#!/bin/sh
while true; do
  echo "$(date -u +%H:%M:%S) orbit-reporter token=${ORBIT_TOKEN} status=nominal"
  sleep 5
done
EOF
chmod +x /exam/q4/image/app.sh
cat > /exam/q4/image/Dockerfile <<'EOF'
FROM docker.io/library/alpine:3.20
ENV ORBIT_TOKEN=unset
COPY app.sh /app.sh
CMD ["/app.sh"]
EOF

mkdir -p /tmp/legacy
printf 'FROM docker.io/library/alpine:3.20\nLABEL tool=legacy\nCMD ["echo","legacy"]\n' > /tmp/legacy/Dockerfile
podman build -t localhost/legacy-tool:1.0 /tmp/legacy
podman save -o /exam/q4/legacy-tool.tar localhost/legacy-tool:1.0
podman rmi -f localhost/legacy-tool:1.0
rm -rf /tmp/legacy

# Q5
kubectl -n pegasus create deployment api-gateway --image=nginx:1.27-alpine --replicas=5

# Q6: v1 live behind the Service, v2 deployed but scaled to zero
for v in v1 v2; do
  replicas=3; [ "$v" = v2 ] && replicas=0
  kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: shop-$v
  namespace: vega
spec:
  replicas: $replicas
  selector:
    matchLabels:
      app: shop
      version: $v
  template:
    metadata:
      labels:
        app: shop
        version: $v
    spec:
      containers:
      - name: shop
        image: nginx:1.27-alpine
        command: ["sh", "-c", "echo shop-$v > /usr/share/nginx/html/index.html && exec nginx -g 'daemon off;'"]
        ports:
        - containerPort: 80
EOF
done
kubectl -n vega apply -f - <<'EOF'
apiVersion: v1
kind: Service
metadata:
  name: shop-svc
spec:
  selector:
    app: shop
  ports:
  - port: 80
    targetPort: 80
EOF

kubectl -n lyra rollout status deploy/collector --timeout=180s
kubectl -n pegasus rollout status deploy/api-gateway --timeout=180s
kubectl -n vega rollout status deploy/shop-v1 --timeout=180s

touch /tmp/.setup-done
