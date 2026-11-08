#!/bin/bash
set -e
get() { kubectl -n lumen get ingress shop-ing -o jsonpath="$1"; }

[ "$(get '{.spec.ingressClassName}')" = "nginx" ]
get '{.spec.rules[*].host}' | grep -qw "shop.exam.local"
[ "$(kubectl -n lumen get svc -o name | wc -l)" = "2" ]

curl -s --max-time 5 http://shop.exam.local:30080/catalog | grep -q "catalog service"
curl -s --max-time 5 http://shop.exam.local:30080/checkout | grep -q "checkout service"
