#!/bin/bash
set -e
get() { kubectl -n hydra get svc hydra-svc -o jsonpath="$1"; }

[ "$(get '{.spec.type}')" = "NodePort" ]
[ "$(get '{.spec.ports[0].port}')" = "8080" ]
[ "$(get '{.spec.ports[0].nodePort}')" = "30180" ]
curl -s --max-time 5 172.30.2.2:30180 | grep -q "It works!"
grep -q "It works!" /exam/q1/response
