# Exit immediately if a command exits with a non-zero status
set -e

if [ $# -ne 2 ]; then
    echo "Usage: $0 session_name path/to/crypto/token/file"
    exit 1
fi

source "$(dirname $0)/find_dirs.sh"

SESSION_NAME="$1"
set +e
SCREEN_LIST=$(screen -list)
set -e

case "$SCREEN_LIST" in
  *$SESSION_NAME*)
    echo "$SESSION_NAME is already running"
    ;;
  *)
    echo "starting $SESSION_NAME"
    screen -d -m -S $SESSION_NAME "$MONITORING_DIR/run_monitor.sh" "$@"
    echo "started"
    ;;
esac

echo ""
sleep 1
echo "=== screens"
set +e
screen -list
set -e
