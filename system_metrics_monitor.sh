#!/bin/bash
set -e

echo "starting   : $0"
echo "arguments  : $@"

if [ $# -ne 1 ]; then
    echo "Usage: $0 path/to/crypto/token/file"
    exit 1
fi

source "$(dirname $0)/find_dirs.sh"

# Get absolute path to crypto token
CRYPTO_TOKEN="$1"
if [ ! -f "$CRYPTO_TOKEN" ]; then
  echo "could not find CRYPTO_TOKEN: $CRYPTO_TOKEN"
  exit 1
fi

cd "$(dirname "$CRYPTO_TOKEN")"
CRYPTO_TOKEN_DIR="$(pwd)"
CRYPTO_TOKEN_FILENAME="$(basename "$CRYPTO_TOKEN")"
CRYPTO_TOKEN_FILE="$CRYPTO_TOKEN_DIR/$CRYPTO_TOKEN_FILENAME"

cd "$MONITORING_DIR"
pipenv run python system_metrics_monitor.py "$CRYPTO_TOKEN_FILE"
