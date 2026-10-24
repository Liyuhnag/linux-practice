#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

[ -f .pid ] && kill "$(cat .pid)" 2>/dev/null || true
rm -f app.log app.log.1

python3 logger.py app.log >/dev/null 2>&1 &
echo $! > .pid
sleep 2

# 模拟“轮转”：改名而不是让应用重新打开
mv app.log app.log.1
: > app.log

echo "故障已注入：app.log 被替换，但应用还在写旧文件。"
echo "请阅读 ticket.md，用 tail -f 和 lsof 排查。"
