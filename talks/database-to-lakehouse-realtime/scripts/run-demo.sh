#!/bin/bash
# Run the lakehouse demo steps, pausing between them (assumes 01-deploy.sh has run)
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
pause() { read -r -p "Press Enter to continue..." _; echo ""; }

"$DIR/02-insert-and-query.sh";  pause
"$DIR/03-schema-evolution.sh";  pause
"$DIR/04-time-travel.sh"

echo ""
echo "Demo complete. Remove everything with: $DIR/99-teardown.sh"
