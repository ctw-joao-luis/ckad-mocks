#!/bin/bash
set -e
get() { kubectl -n orbit get deploy slowpoke -o jsonpath="$1"; }
c='{.spec.template.spec.containers[?(@.name=="web")]'

[ "$(get "${c}.startupProbe.httpGet.path}")" = "/" ]
[ "$(get "${c}.startupProbe.httpGet.port}")" = "80" ]
[ "$(get "${c}.startupProbe.periodSeconds}")" = "5" ]
[ "$(get "${c}.startupProbe.failureThreshold}")" = "6" ]
[ "$(get "${c}.livenessProbe.tcpSocket.port}")" = "80" ]
[ "$(get "${c}.livenessProbe.periodSeconds}")" = "10" ]
kubectl -n orbit rollout status deploy/slowpoke --timeout=5s >/dev/null
[ "$(get '{.status.readyReplicas}')" = "1" ]
