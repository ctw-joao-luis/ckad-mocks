#!/bin/bash
set -e
sc() { kubectl get sc archive-retain -o jsonpath="$1"; }
pvc() { kubectl -n vault get pvc archive-pvc -o jsonpath="$1"; }

[ "$(sc '{.provisioner}')" = "exam.local/archiver" ]
[ "$(sc '{.reclaimPolicy}')" = "Retain" ]
[ "$(sc '{.allowVolumeExpansion}')" = "true" ]

[ "$(pvc '{.spec.storageClassName}')" = "archive-retain" ]
[ "$(pvc '{.spec.resources.requests.storage}')" = "2Gi" ]
pvc '{.spec.accessModes}' | grep -q "ReadWriteOnce"
[ "$(pvc '{.status.phase}')" = "Pending" ]

grep -qi "external provisioner" /exam/q6/reason
grep -q "exam.local/archiver" /exam/q6/reason
