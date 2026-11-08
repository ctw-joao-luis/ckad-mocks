#!/bin/bash
set -e

[ "$(kubectl -n quasar get pod vst-a81c -o jsonpath='{.status.phase}')" = "Running" ]
[ "$(kubectl -n quasar get pod vst-a81c -o jsonpath='{.metadata.labels.system}')" = "ledger" ]
[ "$(kubectl -n quasar get pod vst-a81c -o jsonpath='{.metadata.labels.tier}')" = "backend" ]
[ -z "$(kubectl -n vesta get pod -l system=ledger,tier=backend -o name)" ]

[ "$(kubectl -n vesta get pod -l 'tier in (db,cache),audited=yes' -o name | wc -l)" = "3" ]
[ "$(kubectl -n vesta get pod -l 'tier notin (db,cache),audited=yes' -o name | wc -l)" = "0" ]
