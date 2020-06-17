#!/bin/bash
set -e

# Run a the system_metrics_monitor.sh in a loop and log its output.
# If it crashes, wait 5 min, then restart the monitor driver
#
# Usage: run_monitor.sh <session-name> ... monitor args here ...
#
# For example: run_monitor.sh kk_monitoring path/to/crypto/token

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

# Get path to logfile
LOGFILE="$LOGS_DIR/$SESSION_NAME-$(date "+%Y-%m-%d-%H-%M-%S").log"

while true; do
  cd "$MONITORING_DIR"
  echo "=============================================="
  echo ""
  echo "   Starting  : $SESSION_NAME"
  echo "   Full path : $MONITORING_DIR/system_metrics_monitor.sh"
  echo "   Log file  : $LOGFILE"
  echo ""
  echo "   ctrl-c        : terminate process"
  echo "   ctrl-a ctrl-d : exit screen without terminating process"
  echo ""
  echo "=============================================="
  set +e
  # The pipe hides the exit code.
  # See https://unix.stackexchange.com/questions/14270/get-exit-status-of-process-thats-piped-to-another
  "$MONITORING_DIR/system_metrics_monitor.sh" "$@" 2>&1 | tee -a "$LOGFILE"
  MONITOR_EXIT_CODE=${PIPESTATUS[0]}
  set -e
  echo "=== system_metrics_monitor.sh has terminated with exit code $MONITOR_EXIT_CODE" | tee -a "$LOGFILE"
  echo "sleeping..." | tee -a "$LOGFILE"
  sleep 300
done
