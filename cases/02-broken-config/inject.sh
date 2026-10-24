#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

rm -f app/config.yml
rm -rf config
mkdir -p config

# 指向一个不存在的目标：断链
ln -s ../config/app.yml app/config.yml

echo "故障已注入：app/config.yml 是一个断链。"
echo "请阅读 ticket.md，然后执行 ./app/run.sh。"
