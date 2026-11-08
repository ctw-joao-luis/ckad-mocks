#!/bin/bash
set -e
get() { kubectl -n orion get deploy web-init -o jsonpath="$1"; }

grep -q "prep" /exam/q2/web-init.yaml
[ "$(get '{.spec.template.spec.initContainers[?(@.name=="prep")].image}')" = "busybox:1.36" ]
get '{.spec.template.spec.initContainers[?(@.name=="prep")].volumeMounts[*].name}' | grep -qw content
[ "$(get '{.status.readyReplicas}')" = "1" ]

ip=$(kubectl -n orion get pod -l app=web-init --field-selector=status.phase=Running -o jsonpath='{.items[0].status.podIP}')
curl -s --max-time 5 "$ip" | grep -q "ready to serve"
