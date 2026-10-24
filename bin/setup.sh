#!/usr/bin/env bash
# 生成 / 重建练习样本。用法：./bin/setup.sh [01|02|...|08]
# 只在本仓库目录内创建和删除文件。
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

only="${1:-all}"

need() { command -v "$1" >/dev/null 2>&1 || { echo "缺少命令：$1" >&2; exit 1; }; }
need python3

# 清空某个练习目录，但保留 README.md
clean_dir() {
  local d="$1"
  mkdir -p "$d"
  find "$d" -mindepth 1 -maxdepth 1 ! -name 'README.md' -exec rm -rf {} +
}

# ---------------------------------------------------------------- 01
setup_01() {
  local d="01-文件与目录"
  clean_dir "$d"
  mkdir -p "$d/project/src" "$d/project/docs" "$d/project/tests/deep/nested" "$d/many-files" "$d/empty-dir"

  printf 'def main():\n    print("hello")\n' > "$d/project/src/main.py"
  printf '# 项目说明\n' > "$d/project/docs/readme.md"
  printf 'print("test")\n' > "$d/project/tests/deep/nested/test_main.py"
  printf 'key: value\n' > "$d/project/config.yml"

  printf 'original content\n' > "$d/original.txt"
  ln "$d/original.txt" "$d/hardlink.txt"
  ln -s project/src/main.py "$d/link-to-main"
  ln -s ./missing.txt "$d/broken-link"
  ln -s ../shared/config.yml "$d/relative-link"

  printf 'hidden treasure\n' > "$d/.hidden-file"
  printf 'space in name\n' > "$d/with space.txt"
  printf 'dash file\n' > "$d/-dash-file.txt"
  printf 'trailing space\n' > "$d/config.yaml "

  local i
  for i in $(seq -w 1 120); do : > "$d/many-files/file-$i.txt"; done
  printf 'old 1\n' > "$d/many-files/old-1.txt"
  printf 'old 2\n' > "$d/many-files/old-2.txt"
  printf 'old 3\n' > "$d/many-files/old-3.txt"
  touch -t 202401010000 "$d/many-files/old-1.txt"
  touch -t 202406010000 "$d/many-files/old-2.txt"
  touch -t 202501010000 "$d/many-files/old-3.txt"
}

# ---------------------------------------------------------------- 02
setup_02() {
  local d="02-查看与文本"
  clean_dir "$d"
  mkdir -p "$d/logs"
  python3 - "$d" <<'PY'
import random, datetime, pathlib, sys
random.seed(42)
base = pathlib.Path(sys.argv[1])
ips = ["10.0.0.1","10.0.0.2","192.168.1.5","172.16.0.9","8.8.8.8","1.1.1.1"]
paths = ["/","/api/users","/api/orders","/login","/static/app.js","/health"]
codes = [200,200,200,200,200,304,404,500,502,504]
lines = []
t = datetime.datetime(2026,10,20,9,0,0)
for _ in range(2000):
    t += datetime.timedelta(seconds=random.randint(1,30))
    lines.append(
        f'{random.choice(ips)} - - [{t.strftime("%d/%b/%Y:%H:%M:%S +0800")}] '
        f'"GET {random.choice(paths)} HTTP/1.1" {random.choice(codes)} {random.randint(100,9000)}'
    )
(base/"logs/access.log").write_text("\n".join(lines) + "\n")
(base/"logs/error.log").write_text("""2026-10-20 09:12:01 [error] upstream timed out (110: Connection timed out) while reading response header from upstream, client: 10.0.0.2, server: app.example.com, request: "GET /api/orders HTTP/1.1", upstream: "http://127.0.0.1:8080/api/orders"
2026-10-20 09:12:07 [error] connect() failed (111: Connection refused) while connecting to upstream, client: 192.168.1.5, request: "GET /login HTTP/1.1", upstream: "http://127.0.0.1:8080/login"
2026-10-20 09:15:33 [error] no live upstreams while connecting to upstream, client: 8.8.8.8, request: "GET /api/users HTTP/1.1"
2026-10-20 09:20:11 [warn] conflicting server name "app.example.com" on 0.0.0.0:80, ignored
2026-10-20 09:26:40 [error] upstream timeout (110: Connection timed out) while reading response header from upstream, client: 172.16.0.9, request: "GET /api/users HTTP/1.1"
2026-10-20 09:31:45 [error] upstream timed out (110: Connection timed out) while reading response header from upstream, client: 10.0.0.1, request: "GET /health HTTP/1.1"
""")
(base/"long-lines.txt").write_text(("\n".join("x"*300 for _ in range(50))) + "\n")
(base/"numbers.csv").write_text("""name,age,city
alice,30,beijing
bob,25,shanghai
carol,35,shenzhen
dave,28,beijing
eve,32,hangzhou
""")
(base/"notes.txt").write_text("""line 1: apple
line 2: banana
line 3: cherry
line 4: apple pie
line 5: date
line 6: elderberry
line 7: fig
line 8: grape
line 9: apple juice
line 10: kiwi
""")
(base/"crlf.txt").write_bytes(b"windows line\r\nsecond line\r\n")
PY
}

# ---------------------------------------------------------------- 03
setup_03() {
  local d="03-进程与系统"
  clean_dir "$d"
  mkdir -p "$d/scripts"
  cat > "$d/scripts/busy.sh" <<'SH'
#!/usr/bin/env bash
# 制造 CPU 负载：./busy.sh [秒数]，默认 60
end=$((SECONDS+${1:-60}))
while [ $SECONDS -lt $end ]; do :; done
SH
  cat > "$d/scripts/sleeper.sh" <<'SH'
#!/usr/bin/env bash
# 长时间睡眠，方便练 ps / kill
sleep "${1:-600}"
SH
  cat > "$d/scripts/zombie.py" <<'PY'
#!/usr/bin/env python3
"""子进程立即退出、父进程不 wait，制造一个僵尸。
用法：./zombie.py &
练习：ps -eo pid,ppid,stat,comm | awk '$3 ~ /^Z/'
"""
import os, sys, time

pid = os.fork()
if pid == 0:
    sys.exit(0)

print(f"parent={os.getpid()} child={pid} (child 变成僵尸)")
sys.stdout.flush()
time.sleep(600)
PY
  chmod +x "$d/scripts/"*
}

# ---------------------------------------------------------------- 04
setup_04() {
  local d="04-磁盘与IO"
  clean_dir "$d"
  mkdir -p "$d/small-files"
  python3 - "$d" <<'PY'
import pathlib, sys
base = pathlib.Path(sys.argv[1])
with open(base/"sparse.img", "wb") as f:
    f.seek(1024*1024*1024 - 1)
    f.write(b"\0")
for i in range(300):
    (base/"small-files"/f"f{i}.txt").write_text("x")
PY
}

# ---------------------------------------------------------------- 05
setup_05() {
  mkdir -p "05-网络"
}

# ---------------------------------------------------------------- 06
setup_06() {
  local d="06-权限与用户"
  clean_dir "$d"
  mkdir -p "$d/restricted" "$d/shared"
  printf 'owner only\n'   > "$d/private.txt";  chmod 600 "$d/private.txt"
  printf 'read all\n'     > "$d/public.txt";   chmod 644 "$d/public.txt"
  printf 'inside\n'       > "$d/restricted/secret.txt"
  chmod 700 "$d/restricted"
  printf 'no execute\n'   > "$d/noexec.sh";    chmod 644 "$d/noexec.sh"
  printf '#!/usr/bin/env bash\necho hello\n' > "$d/exec.sh"; chmod 755 "$d/exec.sh"
  chmod 777 "$d/shared"
}

# ---------------------------------------------------------------- 07
setup_07() {
  local d="07-服务与定时"
  clean_dir "$d"
  mkdir -p "$d/systemd" "$d/logs"
  cat > "$d/systemd/practice.service" <<'UNIT'
[Unit]
Description=Practice service for journalctl drills
After=network.target

[Service]
Type=simple
ExecStart=/bin/bash -c 'while true; do echo "practice tick $(date +%T)"; sleep 5; done'
Restart=always
RestartSec=2

[Install]
WantedBy=multi-user.target
UNIT

  cat > "$d/systemd/logrotate-practice.conf" <<'ROT'
/var/log/practice/*.log {
    daily
    rotate 3
    compress
    missingok
    notifempty
    copytruncate
}
ROT

  cat > "$d/crontab.example" <<'CRON'
# 每分钟把时间写进日志（练习用，先 crontab -l 确认再装）
* * * * * /bin/date >> /tmp/practice-cron.log 2>&1
CRON
}

# ---------------------------------------------------------------- 08
setup_08() {
  local d="08-归档与传输"
  clean_dir "$d"
  mkdir -p "$d/source/sub" "$d/source/empty"
  printf 'a\n' > "$d/source/a.txt"
  printf 'b\n' > "$d/source/b.log"
  printf 'c\n' > "$d/source/sub/c.txt"
}

case "$only" in
  all)
    setup_01; setup_02; setup_03; setup_04; setup_05; setup_06; setup_07; setup_08
    echo "样本已生成：01–08"
    ;;
  01|02|03|04|05|06|07|08)
    "setup_$only"
    echo "样本已重建：$only"
    ;;
  *)
    echo "用法：$0 [01|02|03|04|05|06|07|08]" >&2
    exit 1
    ;;
esac
