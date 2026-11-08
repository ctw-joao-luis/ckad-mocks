# Q4 - Container Images

`/exam/q4/image` contains the build files for a small app that writes status lines to stdout. A registry is running at `registry.exam.local:5000`.

> Use `podman` for all tasks. Run as root.

1. Change the Dockerfile: set the ENV variable `ORBIT_TOKEN` to the fixed value `c7e4a1f0-93b2-4d6e-8a15-2f0b9d3c6e71`
2. Build the image, tag it `registry.exam.local:5000/orbit-reporter:v2`, and push it to the registry
3. Run a detached container named `orbit-reporter` from that image and keep it running
4. Write the logs of `orbit-reporter` to `/exam/q4/logs`
5. A colleague exported an image to `/exam/q4/legacy-tool.tar`. Load it into the local image store

<details>
<summary>Solution</summary>

```
cd /exam/q4/image
sed -i 's/^ENV ORBIT_TOKEN=.*/ENV ORBIT_TOKEN=c7e4a1f0-93b2-4d6e-8a15-2f0b9d3c6e71/' Dockerfile

podman build -t registry.exam.local:5000/orbit-reporter:v2 .
podman push registry.exam.local:5000/orbit-reporter:v2

podman run -d --name orbit-reporter registry.exam.local:5000/orbit-reporter:v2
sleep 6
podman logs orbit-reporter > /exam/q4/logs

podman load -i /exam/q4/legacy-tool.tar
podman images
```

</details>
