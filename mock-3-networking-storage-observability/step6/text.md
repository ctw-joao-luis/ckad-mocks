# Q6 - StorageClass

Team Vault also wants archive storage that survives claim deletion.

1. Create a *StorageClass* `archive-retain`:
   - provisioner `exam.local/archiver`
   - reclaimPolicy `Retain`
   - volume expansion allowed
2. In *Namespace* `vault`, create a *PersistentVolumeClaim* `archive-pvc` using that *StorageClass*, access mode `ReadWriteOnce`, requesting `2Gi`

The provisioner `exam.local/archiver` will be installed by another team later, so the claim will stay `Pending`. Write the event message that explains why to `/exam/q6/reason`.

<details>
<summary>Solution</summary>

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: archive-retain
provisioner: exam.local/archiver
reclaimPolicy: Retain
allowVolumeExpansion: true
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: archive-pvc
  namespace: vault
spec:
  storageClassName: archive-retain
  accessModes: ["ReadWriteOnce"]
  resources:
    requests:
      storage: 2Gi
```

```
kubectl apply -f /exam/q6/archive.yaml
kubectl -n vault describe pvc archive-pvc
kubectl -n vault get events --field-selector involvedObject.name=archive-pvc \
  -o jsonpath='{.items[-1].message}' > /exam/q6/reason
```

</details>
