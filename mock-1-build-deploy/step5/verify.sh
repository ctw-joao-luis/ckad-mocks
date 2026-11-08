#!/bin/bash
set -e
get() { kubectl -n pegasus get deploy api-gateway -o jsonpath="$1"; }

[ "$(get '{.spec.strategy.rollingUpdate.maxSurge}')" = "3" ]
[ "$(get '{.spec.strategy.rollingUpdate.maxUnavailable}')" = "1" ]
[ "$(get '{.spec.template.spec.containers[0].image}')" = "nginx:1.27-alpine" ]
kubectl -n pegasus get rs -o jsonpath='{.items[*].spec.template.spec.containers[0].image}' | grep -q "nginx:1.28-alpine"

rev=$(get '{.metadata.annotations.deployment\.kubernetes\.io/revision}')
[ "$rev" -ge 3 ]
[ "$(tr -d '[:space:]' < /exam/q5/revision)" = "$rev" ]
kubectl -n pegasus rollout status deploy/api-gateway --timeout=5s >/dev/null
