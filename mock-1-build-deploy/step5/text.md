# Q5 - Rolling Update & Rollback

*Deployment* `api-gateway` in *Namespace* `pegasus` runs 5 replicas.

1. Configure its rolling update strategy so that during a rollout:
   - up to `3` *Pods* may be created above the desired count
   - at most `1` *Pod* may be unavailable
2. Roll out a new version: change the image to `nginx:1.28-alpine`
3. The new version causes problems. Roll back to the previous revision
4. Write the revision number that is active **after** the rollback to `/exam/q5/revision`

<details>
<summary>Solution</summary>

```
kubectl -n pegasus patch deploy api-gateway -p \
  '{"spec":{"strategy":{"type":"RollingUpdate","rollingUpdate":{"maxSurge":3,"maxUnavailable":1}}}}'

kubectl -n pegasus set image deploy/api-gateway nginx=nginx:1.28-alpine
kubectl -n pegasus rollout status deploy/api-gateway

kubectl -n pegasus rollout undo deploy/api-gateway
kubectl -n pegasus rollout status deploy/api-gateway
kubectl -n pegasus rollout history deploy/api-gateway
```

A rollback creates a **new** revision, so the answer is `3`, not `1`:

```
echo 3 > /exam/q5/revision
```

</details>
