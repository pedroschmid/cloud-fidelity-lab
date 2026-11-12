#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="cloud-fidelity-emulator"
IMAGE_NAME="cloud-fidelity/aws-emulator"
PORT=9297

mkdir -p "$HOME/.aws/emulator"

if ! docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
    docker build \
        -t "$IMAGE_NAME" \
        -f docker/Dockerfile.emulator \
        docker/
fi

if ! docker inspect "$CONTAINER_NAME" >/dev/null 2>&1; then
    docker run -d \
        --name "$CONTAINER_NAME" \
        --memory=2g \
        --memory-swap=2g \
        --user "$(id -u):$(id -g)" \
        -p "127.0.0.1:${PORT}:${PORT}" \
        -v "$HOME/.aws/emulator:/home/emulator/.aws/emulator" \
        "$IMAGE_NAME" \
        -p "$PORT"
fi

echo "Waiting for AWS Emulator..."

for i in $(seq 1 30); do
    if [[ -f "$HOME/.aws/emulator/$PORT/ca.pem" ]] &&
       curl --silent --fail \
           --cacert "$HOME/.aws/emulator/$PORT/ca.pem" \
           "https://127.0.0.1:$PORT/__admin/health" >/dev/null; then
        echo "AWS Emulator is healthy."
        exit 0
    fi
    sleep 1
done

docker logs "$CONTAINER_NAME"
echo "AWS Emulator failed to become healthy."
exit 1
