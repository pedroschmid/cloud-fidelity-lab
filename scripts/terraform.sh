#!/usr/bin/env bash
set -euo pipefail

EMULATOR_DIR="$HOME/.aws/emulator/9297"

for file in emulator_credentials config ca.pem; do
    if [[ ! -f "$EMULATOR_DIR/$file" ]]; then
        echo "Missing emulator file: $file"
        echo "Start the AWS Emulator first: make up"
        exit 1
    fi
done

if ! curl --silent --fail \
    --cacert "$EMULATOR_DIR/ca.pem" \
    https://127.0.0.1:9297/__admin/health \
    >/dev/null; then
    echo "AWS Emulator is not healthy."
    exit 1
fi

unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN
unset AWS_PROFILE
unset AWS_DEFAULT_PROFILE
unset AWS_WEB_IDENTITY_TOKEN_FILE
unset AWS_ROLE_ARN
unset AWS_ROLE_SESSION_NAME
unset AWS_CONTAINER_CREDENTIALS_RELATIVE_URI
unset AWS_CONTAINER_CREDENTIALS_FULL_URI

export AWS_ENDPOINT_URL="https://127.0.0.1:9297"
export AWS_SHARED_CREDENTIALS_FILE="$EMULATOR_DIR/emulator_credentials"
export AWS_CONFIG_FILE="$EMULATOR_DIR/config"
export AWS_CA_BUNDLE="$EMULATOR_DIR/ca.pem"
export AWS_EC2_METADATA_DISABLED=true
export AWS_DISABLE_HOST_PREFIX_INJECTION=true
export AWS_REGION=us-east-1
export AWS_DEFAULT_REGION=us-east-1

exec terraform -chdir=infra "$@"
