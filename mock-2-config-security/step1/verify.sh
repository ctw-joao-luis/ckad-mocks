#!/bin/bash
set -e

[ "$(kubectl get ns pulsar -o jsonpath='{.metadata.labels.tier}')" = "restricted" ]
expected=$(kubectl get ns -l tier=restricted -o name | cut -d/ -f2 | sort)
actual=$(grep -v '^\s*$' /exam/q1/restricted | tr -d ' ' | sort)
[ "$expected" = "$actual" ]
[ "$(echo "$actual" | wc -l)" -ge 5 ]
