# Q3 - ServiceAccount Tokens

*ServiceAccount* `cosmo-bot` in *Namespace* `andromeda` has a long-lived token stored in a *Secret*. The *Secret* name is unknown.

1. Find that *Secret* and write the **base64-decoded** token to `/exam/q3/token`
2. A new API only accepts tokens issued for the audience `exam-api`. Request a short-lived token for `cosmo-bot` with that audience and write it to `/exam/q3/aud-token`

<details>
<summary>Solution</summary>

```
kubectl -n andromeda get secret
kubectl -n andromeda get secret -o custom-columns=NAME:.metadata.name,SA:.metadata.annotations.kubernetes\.io/service-account\.name

kubectl -n andromeda get secret cb-credentials-x7k2 -o jsonpath='{.data.token}' | base64 -d > /exam/q3/token

kubectl -n andromeda create token cosmo-bot --audience=exam-api > /exam/q3/aud-token
```

</details>
