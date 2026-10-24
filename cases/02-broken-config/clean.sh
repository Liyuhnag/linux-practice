#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
rm -f app/config.yml
rm -rf config
echo "已清理。"
