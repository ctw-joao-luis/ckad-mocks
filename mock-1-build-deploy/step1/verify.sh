#!/bin/bash
set -e
get() { kubectl -n orion get job data-cruncher -o jsonpath="$1"; }

grep -q "data-cruncher" /exam/q1/job.yaml
[ "$(get '{.spec.completions}')" = "4" ]
[ "$(get '{.spec.parallelism}')" = "2" ]
[ "$(get '{.spec.backoffLimit}')" = "3" ]
[ "$(get '{.spec.template.spec.containers[0].name}')" = "cruncher" ]
[ "$(get '{.spec.template.spec.containers[0].image}')" = "busybox:1.36" ]
[ "$(get '{.spec.template.metadata.labels.task}')" = "crunch" ]
[ "$(get '{.status.succeeded}')" = "4" ]
grep -q "processed" /exam/q1/output
