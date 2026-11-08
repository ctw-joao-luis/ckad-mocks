#!/bin/bash
set -e
pv() { kubectl get pv vault-pv -o jsonpath="$1"; }

[ "$(pv '{.spec.capacity.storage}')" = "1Gi" ]
[ "$(pv '{.spec.hostPath.path}')" = "/mnt/vault-data" ]
[ "$(pv '{.spec.storageClassName}')" = "manual" ]
pv '{.spec.accessModes}' | grep -q "ReadWriteOnce"
[ "$(pv '{.status.phase}')" = "Bound" ]
[ "$(pv '{.spec.claimRef.namespace}/{.spec.claimRef.name}')" = "vault/vault-pvc" ]

[ "$(kubectl -n vault get pvc vault-pvc -o jsonpath='{.spec.resources.requests.storage}')" = "500Mi" ]
[ "$(kubectl -n vault get pod vault-writer -o jsonpath='{.spec.volumes[*].persistentVolumeClaim.claimName}')" = "vault-pvc" ]
[ "$(kubectl -n vault exec vault-writer -- cat /data/state.txt)" = "saved" ]
