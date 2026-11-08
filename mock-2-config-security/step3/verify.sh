#!/bin/bash
set -e

expected=$(kubectl -n andromeda get secret cb-credentials-x7k2 -o jsonpath='{.data.token}' | base64 -d)
[ -n "$expected" ]
[ "$(tr -d '[:space:]' < /exam/q3/token)" = "$expected" ]

payload=$(tr -d '[:space:]' < /exam/q3/aud-token | cut -d. -f2 | tr '_-' '/+')
while [ $(( ${#payload} % 4 )) -ne 0 ]; do payload="${payload}="; done
claims=$(echo "$payload" | base64 -d)
echo "$claims" | grep -q '"exam-api"'
echo "$claims" | grep -q 'system:serviceaccount:andromeda:cosmo-bot'
