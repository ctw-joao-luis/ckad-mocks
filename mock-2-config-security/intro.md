# CKAD Mock 2 - Config & Security

**Target time: 45 minutes for 6 tasks.**

Rules, as in the real exam:

- Work on `controlplane`. `node01` is reachable via `ssh node01` if needed.
- Files the tasks refer to are under `/exam/qN/`.
- Use only the official Kubernetes docs (kubernetes.io/docs) as a reference.
- Each task has a **Check** button. Try to solve everything before peeking at a solution.

Useful setup:

```
alias k=kubectl
export do="--dry-run=client -o yaml"
export now="--force --grace-period 0"
```

Wait until the terminal prints **Environment ready** before starting.
