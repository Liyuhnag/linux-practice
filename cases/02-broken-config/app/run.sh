#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

cfg="$PWD/config.yml"

if [ ! -e "$cfg" ]; then
  echo "open $cfg: No such file or directory" >&2
  exit 1
fi

if [ ! -r "$cfg" ]; then
  echo "open $cfg: Permission denied" >&2
  exit 1
fi

echo "config loaded: $(tr -d '\n' < "$cfg")"
