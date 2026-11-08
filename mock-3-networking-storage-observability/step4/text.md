# Q4 - Logs & kubectl debug

*Pod* `glitch` in *Namespace* `orbit` keeps crashing.

1. Write the logs of the **previous, crashed** container instance to `/exam/q4/error.log`
2. Use `kubectl debug` to add an ephemeral container to the *Pod*:
   - Name `inspector`
   - Image `busybox:1.36`
   - Command `sleep 1d`, so it keeps running

<details>
<summary>Solution</summary>

```
kubectl -n orbit get pod glitch
kubectl -n orbit logs glitch --previous > /exam/q4/error.log
cat /exam/q4/error.log

kubectl -n orbit debug glitch --container=inspector --image=busybox:1.36 -- sleep 1d
kubectl -n orbit get pod glitch -o jsonpath='{.spec.ephemeralContainers[*].name}'
```

</details>
