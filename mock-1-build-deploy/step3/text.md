# Q3 - Sidecar, Pull Policy, Termination

*Deployment* `collector` in *Namespace* `lyra` runs an `app` container and a `log-shipper` sidecar as a regular container. Change it so that:

1. `log-shipper` becomes a **native sidecar**: it starts before `app` and keeps running for the whole lifetime of the *Pod*
2. The `app` container pulls its image only if it isn't already on the node
3. The `log-shipper` container never pulls its image
4. *Pods* get up to 45 seconds to shut down gracefully

The *Deployment* must be fully rolled out afterwards.

<details>
<summary>Solution</summary>

```
kubectl -n lyra edit deploy collector
```

Move `log-shipper` from `containers` to `initContainers` and set `restartPolicy: Always` on it:

```yaml
    spec:
      terminationGracePeriodSeconds: 45
      initContainers:
      - name: log-shipper
        image: busybox:1.36
        imagePullPolicy: Never
        restartPolicy: Always
        command: ["sh", "-c", "touch /logs/access.log; tail -F /logs/access.log"]
        volumeMounts:
        - name: logs
          mountPath: /logs
      containers:
      - name: app
        image: nginx:1.27-alpine
        imagePullPolicy: IfNotPresent
        volumeMounts:
        - name: logs
          mountPath: /var/log/nginx
```

```
kubectl -n lyra rollout status deploy/collector
```

</details>
