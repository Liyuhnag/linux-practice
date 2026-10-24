#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
for f in .stray.pid .app.pid; do
  [ -f "$f" ] && kill "$(cat "$f")" 2>/dev/null || true
  rm -f "$f"
done
echo "已清理。"
