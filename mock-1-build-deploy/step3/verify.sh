#!/bin/bash
set -e
get() { kubectl -n lyra get deploy collector -o jsonpath="$1"; }

[ "$(get '{.spec.template.spec.initContainers[?(@.name=="log-shipper")].restartPolicy}')" = "Always" ]
[ "$(get '{.spec.template.spec.initContainers[?(@.name=="log-shipper")].imagePullPolicy}')" = "Never" ]
# "! cmd" does not trigger set -e
if get '{.spec.template.spec.containers[*].name}' | grep -qw log-shipper; then exit 1; fi
[ "$(get '{.spec.template.spec.containers[?(@.name=="app")].imagePullPolicy}')" = "IfNotPresent" ]
[ "$(get '{.spec.template.spec.terminationGracePeriodSeconds}')" = "45" ]
kubectl -n lyra rollout status deploy/collector --timeout=5s >/dev/null
