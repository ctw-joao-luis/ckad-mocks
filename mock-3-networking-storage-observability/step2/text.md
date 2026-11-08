# Q2 - Ingress

*Namespace* `lumen` runs *Deployments* `catalog` and `checkout`, each with a *Service*. An Ingress controller is installed and reachable at `http://shop.exam.local:30080`.

Create an *Ingress* `shop-ing` in *Namespace* `lumen`:

1. Use the existing *IngressClass*
2. Use the existing *Services*; don't create new ones
3. Host `shop.exam.local`
4. Path `/catalog` (prefix) routes to *Pods* of `catalog`
5. Path `/checkout` (prefix) routes to *Pods* of `checkout`

Test it with `curl`.

<details>
<summary>Solution</summary>

```
kubectl get ingressclass
kubectl -n lumen get svc

kubectl -n lumen create ingress shop-ing --class=nginx \
  --rule="shop.exam.local/catalog*=catalog-svc:80" \
  --rule="shop.exam.local/checkout*=checkout-svc:80"

curl shop.exam.local:30080/catalog
curl shop.exam.local:30080/checkout
```

`path*` in `kubectl create ingress` means `pathType: Prefix`.

</details>
