#!/bin/bash
# Stop and remove all demo containers
set -euo pipefail
cd "$(dirname "$0")/.."
docker compose --profile proxy down -v
