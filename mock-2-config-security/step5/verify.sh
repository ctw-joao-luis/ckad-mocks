#!/bin/bash
set -e
get() { kubectl -n sirius get deploy orbit-api -o jsonpath="$1"; }
c='{.spec.template.spec.containers[?(@.name=="api")]'

grep -q "kind: Deployment" /exam/q5/orbit-deploy.yaml
[ "$(get '{.spec.replicas}')" = "2" ]
[ "$(get '{.spec.template.spec.securityContext.runAsUser}')" = "1000" ]
[ "$(get '{.spec.template.spec.securityContext.runAsNonRoot}')" = "true" ]
[ "$(get "${c}.securityContext.allowPrivilegeEscalation}")" = "false" ]
[ "$(get "${c}.securityContext.readOnlyRootFilesystem}")" = "true" ]
get "${c}.securityContext.capabilities.drop}" | grep -q "ALL"
[ "$(get '{.status.readyReplicas}')" = "2" ]

# standalone Pod must be gone; Deployment Pods have generated names
if kubectl -n sirius get pod orbit-api >/dev/null 2>&1; then exit 1; fi
