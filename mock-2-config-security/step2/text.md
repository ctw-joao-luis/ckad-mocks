# Q2 - ServiceAccount, Resources & Quota

Team Andromeda needs 2 *Pods* of image `httpd:2.4-alpine`. Create a *Deployment* named `andro-api` in *Namespace* `andromeda`:

1. Container name `api`
2. The *Pods* run under the existing *ServiceAccount* `andro-runner`
3. Each container requests `50m` CPU and `32Mi` memory
4. Each container is limited to `100m` CPU and `64Mi` memory

Both replicas must be running. The *Namespace* has a *ResourceQuota*; check it if *Pods* don't show up.

<details>
<summary>Solution</summary>

```
kubectl -n andromeda describe quota
kubectl -n andromeda create deploy andro-api --image=httpd:2.4-alpine --replicas=2 \
  --dry-run=client -o yaml > /exam/q2/andro-api.yaml
```

Edit the file:

```yaml
    spec:
      serviceAccountName: andro-runner
      containers:
      - name: api
        image: httpd:2.4-alpine
        resources:
          requests:
            cpu: 50m
            memory: 32Mi
          limits:
            cpu: 100m
            memory: 64Mi
```

```
kubectl apply -f /exam/q2/andro-api.yaml
kubectl -n andromeda get deploy,rs,pod
```

If *Pods* are missing, `kubectl -n andromeda describe rs` shows the quota error.

</details>
