# Q1 - Namespaces & Labels

Some *Namespaces* in the cluster have the label `tier=restricted`.

1. *Namespace* `pulsar` must also become restricted. Change its `tier` label accordingly
2. Write the **names only** of all *Namespaces* with label `tier=restricted` to `/exam/q1/restricted`, one per line

<details>
<summary>Solution</summary>

```
kubectl get ns --show-labels
kubectl label ns pulsar tier=restricted --overwrite

kubectl get ns -l tier=restricted -o name | cut -d/ -f2 > /exam/q1/restricted
# or
kubectl get ns -l tier=restricted -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' > /exam/q1/restricted
```

</details>
