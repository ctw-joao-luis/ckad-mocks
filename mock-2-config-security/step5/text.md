# Q5 - SecurityContext

*Pod* `orbit-api` runs in *Namespace* `sirius`. Its manifest is at `/exam/q5/orbit-pod.yaml`.

1. Convert it into a *Deployment* `orbit-api` with `2` replicas in the same *Namespace*
2. *Pod*-level security: run as user `1000` and refuse to run as root
3. Container-level security for `api`:
   - no privilege escalation
   - read-only root filesystem
   - drop **all** Linux capabilities
4. Save the *Deployment* manifest at `/exam/q5/orbit-deploy.yaml`
5. Delete the original *Pod* once the *Deployment* is running

<details>
<summary>Solution</summary>

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: orbit-api
  namespace: sirius
spec:
  replicas: 2
  selector:
    matchLabels:
      app: orbit-api
  template:
    metadata:
      labels:
        app: orbit-api
    spec:
      securityContext:
        runAsUser: 1000
        runAsNonRoot: true
      containers:
      - name: api
        image: busybox:1.36
        command: ["sh", "-c", "while true; do echo heartbeat; sleep 10; done"]
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          capabilities:
            drop: ["ALL"]
```

```
kubectl apply -f /exam/q5/orbit-deploy.yaml
kubectl -n sirius rollout status deploy/orbit-api
kubectl -n sirius delete pod orbit-api
```

Watch out: the old *Pod* has label `app=orbit-api` too. The ReplicaSet doesn't adopt it because it lacks the `pod-template-hash` label, but `kubectl get pod -l app=orbit-api` shows all three until you delete it.

</details>
