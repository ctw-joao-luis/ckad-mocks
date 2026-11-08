#!/bin/bash
set -e
get() { kubectl -n orbit get pod glitch -o jsonpath="$1"; }

grep -q "FATAL: config /etc/glitch/app.conf not found" /exam/q4/error.log
[ "$(get '{.spec.ephemeralContainers[?(@.name=="inspector")].image}')" = "busybox:1.36" ]
get '{.spec.ephemeralContainers[?(@.name=="inspector")].command}{.spec.ephemeralContainers[?(@.name=="inspector")].args}' | grep -q "sleep"
[ -n "$(get '{.status.ephemeralContainerStatuses[?(@.name=="inspector")].state.running}')" ]
