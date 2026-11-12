#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if ! curl --silent --fail \
    --cacert "$HOME/.aws/emulator/9297/ca.pem" \
    https://127.0.0.1:9297/__admin/health \
    >/dev/null; then
    echo "AWS Emulator is unavailable. Run 'make up' first."
    exit 1
fi

export AWS_EC2_METADATA_DISABLED=true

exec .venv/bin/python -m pytest \
    tests/test_infrastructure.py \
    -v
