# Q1 - Job

Create a *Job* manifest at `/exam/q1/job.yaml` for *Namespace* `orion`:

1. Job name `data-cruncher`, container name `cruncher`
2. Image `busybox:1.36`, command `sh -c "sleep 3 && echo processed"`
3. 4 completions in total, at most 2 *Pods* running in parallel
4. The Job should give up after 3 failed retries
5. *Pods* are labelled `task: crunch`

Apply the manifest. When the Job has finished, write the logs of **one** of its *Pods* to `/exam/q1/output`.

<details>
<summary>Solution</summary>

```
kubectl -n orion create job data-cruncher --image=busybox:1.36 \
  --dry-run=client -o yaml -- sh -c "sleep 3 && echo processed" > /exam/q1/job.yaml
```

Edit `/exam/q1/job.yaml`:

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: data-cruncher
  namespace: orion
spec:
  completions: 4
  parallelism: 2
  backoffLimit: 3
  template:
    metadata:
      labels:
        task: crunch
    spec:
      containers:
      - name: cruncher
        image: busybox:1.36
        command: ["sh", "-c", "sleep 3 && echo processed"]
      restartPolicy: Never
```

```
kubectl apply -f /exam/q1/job.yaml
kubectl -n orion get job,pod -l task=crunch -w
kubectl -n orion logs $(kubectl -n orion get pod -l task=crunch -o name | head -1) > /exam/q1/output
```

</details>
