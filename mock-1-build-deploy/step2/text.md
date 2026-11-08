# Q2 - InitContainer

The *Deployment* manifest at `/exam/q2/web-init.yaml` runs nginx and serves files from an empty volume. It has not been applied yet.

Edit the file and add an *InitContainer*:

1. Name `prep`, image `busybox:1.36`
2. It mounts the same volume as the nginx container
3. It writes `ready to serve` into `index.html` at the root of that volume

Apply the file, then use `curl` against the *Pod* IP to check that nginx serves the content.

<details>
<summary>Solution</summary>

Add under `spec.template.spec`:

```yaml
      initContainers:
      - name: prep
        image: busybox:1.36
        command: ["sh", "-c", "echo 'ready to serve' > /work/index.html"]
        volumeMounts:
        - name: content
          mountPath: /work
```

```
kubectl apply -f /exam/q2/web-init.yaml
kubectl -n orion rollout status deploy/web-init
curl $(kubectl -n orion get pod -l app=web-init -o jsonpath='{.items[0].status.podIP}')
```

</details>
