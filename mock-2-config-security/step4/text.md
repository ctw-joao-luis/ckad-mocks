# Q4 - ConfigMap & Secret

*Deployment* `starlight` in *Namespace* `nebula` mounts a *ConfigMap* that doesn't exist yet, so its *Pod* is stuck.

1. Create *ConfigMap* `starlight-html` with the content of `/exam/q4/index.html` under the data key `index.html`
2. Create *Secret* `starlight-db` with the keys `DB_USER=admin` and `DB_PASS=s3cr3t-pass`
3. Change the *Deployment* so that **all** keys of `starlight-db` are available as environment variables in container `web`

Use `curl` against the *Pod* to check that nginx serves the HTML.

<details>
<summary>Solution</summary>

```
kubectl -n nebula create configmap starlight-html --from-file=index.html=/exam/q4/index.html
kubectl -n nebula create secret generic starlight-db \
  --from-literal=DB_USER=admin --from-literal=DB_PASS=s3cr3t-pass

kubectl -n nebula set env deploy/starlight --from=secret/starlight-db
# or edit and add under container "web":
#   envFrom:
#   - secretRef:
#       name: starlight-db

kubectl -n nebula rollout status deploy/starlight
kubectl -n nebula exec deploy/starlight -- env | grep DB_
curl $(kubectl -n nebula get pod -l app=starlight -o jsonpath='{.items[0].status.podIP}')
```

`kubectl set env --from` creates one `valueFrom.secretKeyRef` entry per key. `envFrom` is shorter; both pass.

</details>
