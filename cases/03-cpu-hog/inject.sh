#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

[ -f .pid ] && kill "$(cat .pid)" 2>/dev/null || true
mkdir -p bin

cat > bin/report-worker <<'WORKER'
#!/usr/bin/env bash
# 模拟一个失控的报表进程
while :; do :; done
WORKER
chmod +x bin/report-worker

./bin/report-worker >/dev/null 2>&1 &
echo $! > .pid
sleep 1

echo "故障已注入：一个叫 report-worker 的进程在吃 CPU。"
echo "请阅读 ticket.md，用 top / ps 找到它。"
