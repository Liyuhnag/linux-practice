#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

# 清掉上一次的残留
[ -f .stray.pid ] && kill "$(cat .stray.pid)" 2>/dev/null || true
[ -f .app.pid ] && kill "$(cat .app.pid)" 2>/dev/null || true
sleep 0.3

# 制造一个“遗留进程”占住 18080
python3 -m http.server 18080 --bind 127.0.0.1 >/dev/null 2>&1 &
echo $! > .stray.pid
sleep 1

echo "故障已注入：18080 被一个遗留进程占用。"
echo "请阅读 ticket.md，然后执行 ./run.sh。"
