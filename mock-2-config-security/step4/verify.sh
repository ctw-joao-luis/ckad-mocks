#!/bin/bash
set -e

[ "$(kubectl -n nebula get cm starlight-html -o jsonpath='{.data.index\.html}')" = "$(cat /exam/q4/index.html)" ]
[ "$(kubectl -n nebula get secret starlight-db -o jsonpath='{.data.DB_USER}' | base64 -d)" = "admin" ]
[ "$(kubectl -n nebula get secret starlight-db -o jsonpath='{.data.DB_PASS}' | base64 -d)" = "s3cr3t-pass" ]
kubectl -n nebula rollout status deploy/starlight --timeout=5s >/dev/null

env_out=$(kubectl -n nebula exec deploy/starlight -c web -- env)
echo "$env_out" | grep -qx "DB_USER=admin"
echo "$env_out" | grep -qx "DB_PASS=s3cr3t-pass"

ip=$(kubectl -n nebula get pod -l app=starlight --field-selector=status.phase=Running -o jsonpath='{.items[0].status.podIP}')
curl -s --max-time 5 "$ip" | grep -q "Starlight Observatory"
