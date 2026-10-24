#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
[ -f .pid ] && kill "$(cat .pid)" 2>/dev/null || true
rm -f .pid
echo "已清理。"
