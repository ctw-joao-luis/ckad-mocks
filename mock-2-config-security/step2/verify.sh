#!/bin/bash
set -e
get() { kubectl -n andromeda get deploy andro-api -o jsonpath="$1"; }
c='{.spec.template.spec.containers[?(@.name=="api")]'

[ "$(get "${c}.image}")" = "httpd:2.4-alpine" ]
[ "$(get '{.spec.template.spec.serviceAccountName}')" = "andro-runner" ]
[ "$(get "${c}.resources.requests.cpu}")" = "50m" ]
[ "$(get "${c}.resources.requests.memory}")" = "32Mi" ]
[ "$(get "${c}.resources.limits.cpu}")" = "100m" ]
[ "$(get "${c}.resources.limits.memory}")" = "64Mi" ]
[ "$(get '{.status.readyReplicas}')" = "2" ]
