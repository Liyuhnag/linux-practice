#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
[ -f .pid ] && kill "$(cat .pid)" 2>/dev/null || true
rm -f .pid app.log app.log.1
echo "已清理。"
