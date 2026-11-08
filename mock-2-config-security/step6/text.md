# Q6 - Labels & Selectors

*Namespace* `vesta` runs several *Pods* with generated-looking names.

1. The **backend** *Pod* of system `ledger` belongs in *Namespace* `quasar`. Find it and move it there, keeping its name and labels. Recreating it is fine
2. Add the label `audited=yes` to every *Pod* in `vesta` whose `tier` is either `db` or `cache`

<details>
<summary>Solution</summary>

```
kubectl -n vesta get pod --show-labels
kubectl -n vesta get pod -l system=ledger,tier=backend

kubectl -n vesta get pod vst-a81c -o yaml > /exam/q6/ledger.yaml
```

In `/exam/q6/ledger.yaml`, change `metadata.namespace` to `quasar` and remove `status`, `metadata.uid`, `metadata.resourceVersion` and `metadata.creationTimestamp`.

```
kubectl apply -f /exam/q6/ledger.yaml
kubectl -n quasar get pod vst-a81c
kubectl -n vesta delete pod vst-a81c

kubectl -n vesta label pod -l 'tier in (db,cache)' audited=yes
kubectl -n vesta get pod -L tier,audited
```

</details>
