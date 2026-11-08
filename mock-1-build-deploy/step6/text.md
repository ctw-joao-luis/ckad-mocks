# Q6 - Blue-Green Switch

In *Namespace* `vega`, *Deployment* `shop-v1` is live behind *Service* `shop-svc`. The new version, `shop-v2`, is deployed but scaled to 0.

Switch the traffic over in blue-green fashion:

1. Scale `shop-v2` to `3` replicas and wait until they are ready
2. Change `shop-svc` so it sends traffic **only** to `shop-v2` *Pods*
3. Scale `shop-v1` down to `0`
4. `curl` the *Service* and write the response to `/exam/q6/response`

<details>
<summary>Solution</summary>

```
kubectl -n vega scale deploy shop-v2 --replicas=3
kubectl -n vega rollout status deploy/shop-v2

kubectl -n vega get pod --show-labels
kubectl -n vega patch svc shop-svc -p '{"spec":{"selector":{"app":"shop","version":"v2"}}}'
kubectl -n vega get endpointslice -l kubernetes.io/service-name=shop-svc

kubectl -n vega scale deploy shop-v1 --replicas=0

curl -s $(kubectl -n vega get svc shop-svc -o jsonpath='{.spec.clusterIP}') > /exam/q6/response
cat /exam/q6/response
```

</details>
