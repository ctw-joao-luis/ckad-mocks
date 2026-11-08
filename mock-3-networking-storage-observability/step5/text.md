# Q5 - PersistentVolume & Claim

Team Vault needs persistent storage without a dynamic provisioner.

1. Create a *PersistentVolume* `vault-pv`:
   - capacity `1Gi`, access mode `ReadWriteOnce`
   - `hostPath` `/mnt/vault-data`
   - storageClassName `manual`
2. In *Namespace* `vault`, create a *PersistentVolumeClaim* `vault-pvc` requesting `500Mi` with access mode `ReadWriteOnce` and storageClassName `manual`. It must bind to `vault-pv`
3. In *Namespace* `vault`, create a *Pod* `vault-writer`, image `busybox:1.36`, that mounts the claim at `/data` and runs `sh -c "echo saved > /data/state.txt && sleep 1d"`

<details>
<summary>Solution</summary>

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: vault-pv
spec:
  capacity:
    storage: 1Gi
  accessModes: ["ReadWriteOnce"]
  storageClassName: manual
  hostPath:
    path: /mnt/vault-data
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: vault-pvc
  namespace: vault
spec:
  accessModes: ["ReadWriteOnce"]
  storageClassName: manual
  resources:
    requests:
      storage: 500Mi
---
apiVersion: v1
kind: Pod
metadata:
  name: vault-writer
  namespace: vault
spec:
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: vault-pvc
  containers:
  - name: vault-writer
    image: busybox:1.36
    command: ["sh", "-c", "echo saved > /data/state.txt && sleep 1d"]
    volumeMounts:
    - name: data
      mountPath: /data
```

```
kubectl apply -f /exam/q5/vault.yaml
kubectl get pv vault-pv
kubectl -n vault get pvc,pod
kubectl -n vault exec vault-writer -- cat /data/state.txt
```

</details>
