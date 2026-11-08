#!/bin/bash
set -e

[ "$(kubectl -n vega get svc shop-svc -o jsonpath='{.spec.selector.version}')" = "v2" ]
[ "$(kubectl -n vega get deploy shop-v2 -o jsonpath='{.status.readyReplicas}')" = "3" ]
[ "$(kubectl -n vega get deploy shop-v1 -o jsonpath='{.spec.replicas}')" = "0" ]

endpoints=$(kubectl -n vega get endpointslice -l kubernetes.io/service-name=shop-svc \
  -o jsonpath='{range .items[*].endpoints[*]}{.addresses[0]}{"\n"}{end}' | grep -c .)
[ "$endpoints" = "3" ]

grep -q "shop-v2" /exam/q6/response
