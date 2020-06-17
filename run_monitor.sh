#!/bin/bash
set -e

# Run a monitor driver
# If it crashes, wait 5 min, then restart the monitor driver
#
# Usage: run_driver.sh <monitor-name> ... monitor args here ...
#
# For example: run_driver.sh kk_monitor.sh path/to/crypto/token

if [ $# -ne 2 ]; then
    echo "Usage: $0 session_name path/to/crypto/token/file"
    exit 1
fi

# from https://developer.ibm.com/technologies/systems/articles/au-usingtraps/
handle_ctrl_c() {
  echo ""
  echo "ctrl-c pressed"
  echo "exiting run_driver.sh"
  exit 0
}
trap handle_ctrl_c SIGINT

source "$(dirname $0)/find_dirs.sh"

# Get the session name
SESSION_NAME="$1"
shift

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

# Get path to logfile
LOGFILE="$LOGS_DIR/$SESSION_NAME-$(date "+%Y-%m-%d-%H-%M-%S").log"

while true; do
  cd "$MONITORING_DIR"
  echo "=============================================="
  echo ""
  echo "   Starting  : $SESSION_NAME"
  echo "   Full path : $MONITORING_DIR/system_metrics_monitor.py"
  echo "   Log file  : $LOGFILE"
  echo ""
  echo "   ctrl-c        : terminate process"
  echo "   ctrl-a ctrl-d : exit screen without terminating process"
  echo ""
  echo "=============================================="
  set +e
  # The pipe hides the exit code.
  # See https://unix.stackexchange.com/questions/14270/get-exit-status-of-process-thats-piped-to-another
  pipenv run python "system_metrics_monitor.py" "$CRYPTO_TOKEN_FILE" 2>&1 | tee -a "$LOGFILE"
  MONITOR_EXIT_CODE=${PIPESTATUS[0]}
  set -e
  echo "=== system_metrics_monitor.py has terminated with exit code $MONITOR_EXIT_CODE" | tee -a "$LOGFILE"
  echo "sleeping..." | tee -a "$LOGFILE"
  sleep 300
done