#!/usr/bin/env bash
set -euo pipefail

docker rm -f cloud-fidelity-emulator 2>/dev/null || true

echo "AWS Emulator stopped."
