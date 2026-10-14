#!/bin/bash
# Run the complete proxy validation demo, pausing between steps
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"

pause() { read -r -p "Press Enter to continue..." _; echo ""; }

"$DIR/00-start.sh";            pause
"$DIR/01-register-schema.sh";  pause
"$DIR/02-create-topic.sh";     pause
"$DIR/03-produce-valid.sh";    pause
"$DIR/04-produce-invalid.sh";  pause
"$DIR/05-verify-kafka.sh";     pause
"$DIR/06-mixed-batch.sh";      pause
"$DIR/05-verify-kafka.sh";     pause
"$DIR/07-bypass.sh";           pause
"$DIR/08-registry-outage.sh"

echo ""
echo "Demo complete. Clean up with: $DIR/99-stop.sh"
