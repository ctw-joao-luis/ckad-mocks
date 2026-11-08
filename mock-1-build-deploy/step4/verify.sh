#!/bin/bash
set -e
img=registry.exam.local:5000/orbit-reporter:v2
token=c7e4a1f0-93b2-4d6e-8a15-2f0b9d3c6e71

grep -q "$token" /exam/q4/image/Dockerfile
podman image inspect "$img" --format '{{.Config.Env}}' | grep -q "ORBIT_TOKEN=$token"
curl -s --max-time 5 http://registry.exam.local:5000/v2/orbit-reporter/tags/list | grep -q '"v2"'
[ "$(podman inspect orbit-reporter --format '{{.State.Running}}')" = "true" ]
podman inspect orbit-reporter --format '{{.ImageName}}' | grep -q "$img"
grep -q "token=$token" /exam/q4/logs
podman image exists localhost/legacy-tool:1.0
