# Exit immediately if a command exits with a non-zero status
set -e
if [ $# -ne 1 ]; then
    echo "Usage: $0 path/to/crypto/token/file"
    exit 1
fi

WORK_DIR="$(pwd)"

# Get absolute path to script folder
cd "$(dirname "$0")"
SCRIPT_DIR="$(pwd)"

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

cd "$WORK_DIR"

# start monitoring script
SYSTEM_MONITOR_SCRIPT="system_metrics_monitor"
set +e
SCREEN_LIST=$(screen -list)
set -e

case "$SCREEN_LIST" in
  *$SYSTEM_MONITOR_SCRIPT*)
    echo "$SYSTEM_MONITOR_SCRIPT is already running"
    ;;
  *)
    echo "starting $SYSTEM_MONITOR_SCRIPT"
    screen -d -m -S "$SYSTEM_MONITOR_SCRIPT" pipenv run python "$SCRIPT_DIR/$SYSTEM_MONITOR_SCRIPT.py" "$CRYPTO_TOKEN_FILE"
    echo "started"
    ;;
esac

echo ""
sleep 1
echo "=== screens"
set +e
screen -list
set -e
