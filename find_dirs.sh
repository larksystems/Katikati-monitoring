# This script defines directory variables for Katikati-monitoring.
# It is called via
#
#   source "$(dirname $0)/find_dirs.sh"
#
# This script defines the following environmental variables as a result of parsing the arguments:
#
#   MONITORING_DIR     - the absolute path to the Katikati-monitoring directory
#   DEV_DIR            - the directory containing the Katikati-monitoring directory
#   LOGS_DIR           - the directory containing the log files
#   WORK_DIR           - the working directory when the script was launched
#
# If the first argument is "--verbose" then VERBOSE is defined and that argument consumed

WORK_DIR="$(pwd)"

cd "$(dirname "$0")"
MONITORING_DIR="$(pwd)"

cd ..
DEV_DIR="$(pwd)"
LOGS_DIR="$DEV_DIR/Logs"
mkdir -p "$LOGS_DIR"

cd "$WORK_DIR"

if [ x"$1" = x"--verbose" ]; then
  shift
  VERBOSE=True
  echo "MONITORING_DIR     = $MONITORING_DIR"
  echo "DEV_DIR            = $DEV_DIR"
  echo "LOGS_DIR           = $LOGS_DIR"
  echo "WORK_DIR           = $WORK_DIR"
  echo "--- end find_dirs.sh"
fi
