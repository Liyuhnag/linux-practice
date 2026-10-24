#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

for f in .proxy.pid .upstream.pid; do
  [ -f "$f" ] && kill "$(cat "$f")" 2>/dev/null || true
  rm -f "$f"
done
: > proxy.log

python3 proxy.py >/dev/null 2>&1 &
echo $! > .proxy.pid
sleep 1

echo "故障已注入：网关在 18081，上游 18082 没有服务。"
echo "请阅读 ticket.md，用 curl -v 和 ss 排查。"
