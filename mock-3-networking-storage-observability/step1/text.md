# Q1 - NodePort Service

*Namespace* `hydra` runs *Deployment* `hydra-web` (httpd), exposed by the ClusterIP *Service* `hydra-svc` on port `8080`.

1. Change `hydra-svc` to a NodePort *Service* that is reachable on **every** node on port `30180`. Keep the *Service* port `8080`
2. `curl` the internal IP of `node01` on port `30180` and write the response body to `/exam/q1/response`

<details>
<summary>Solution</summary>

```
kubectl -n hydra edit svc hydra-svc
```

```yaml
spec:
  type: NodePort
  ports:
  - port: 8080
    targetPort: 80
    nodePort: 30180
```

```
kubectl get node -o wide
curl -s 172.30.2.2:30180 > /exam/q1/response
cat /exam/q1/response
```

</details>
