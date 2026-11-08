# Q3 - Startup & Liveness Probes

*Deployment* `slowpoke` in *Namespace* `orbit` needs about 20 seconds before nginx accepts connections. Add probes to container `web`:

1. A **startup** probe: HTTP GET on `/` port `80`, checked every `5` seconds, allowing up to `6` failures before the container is restarted
2. A **liveness** probe: TCP check on port `80` every `10` seconds. It must only start once the startup probe has succeeded

The *Deployment* must be fully rolled out afterwards.

<details>
<summary>Solution</summary>

```
kubectl -n orbit edit deploy slowpoke
```

```yaml
      containers:
      - name: web
        ...
        startupProbe:
          httpGet:
            path: /
            port: 80
          periodSeconds: 5
          failureThreshold: 6
        livenessProbe:
          tcpSocket:
            port: 80
          periodSeconds: 10
```

Liveness and readiness probes don't run until the startup probe succeeds, so requirement 2 needs no extra configuration.

```
kubectl -n orbit rollout status deploy/slowpoke
kubectl -n orbit describe pod -l app=slowpoke | grep -A2 -E "Startup|Liveness"
```

</details>
