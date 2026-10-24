# 参考答案

先自己做，卡住再看。只给一种写法，不是唯一解。

## 01 文件与目录

```bash
cd 01-文件与目录

# 1. 7 天内的 .txt
find . -type f -name '*.txt' -mtime -7

# 2. 同一个文件（两种方法）
ls -li original.txt hardlink.txt          # inode 相同
stat -c '%i %h %n' original.txt hardlink.txt

# 3. 断链
find . -xtype l
readlink -f broken-link; test -e broken-link || echo broken

# 4. - 开头的文件
cat -- -dash-file.txt

# 5. 空目录
find . -type d -empty

# 6. 删掉 hardlink.txt
rm hardlink.txt
stat -c 'links=%h' original.txt            # 变成 1，内容还在
```

## 02 查看与文本

```bash
cd 02-查看与文本

# 1. Top 3 IP
awk '{print $1}' logs/access.log | sort | uniq -c | sort -rn | head -3

# 2. 状态码分布
awk '{print $9}' logs/access.log | sort | uniq -c | sort -rn

# 3. timeout 上下文
grep -B1 -A2 timeout logs/error.log

# 4. 响应字节总和
awk '{s+=$10} END {print s}' logs/access.log

# 5. 去 CR
tr -d '\r' < crlf.txt > crlf-fixed.txt

# 6. 为什么先 sort
# uniq 只合并相邻重复行，不排序会把相同 IP 拆散
```

## 03 进程与系统

```bash
cd 03-进程与系统

# 1. CPU 前 5
ps -eo pid,%cpu,comm --sort=-%cpu | head -6

# 2. 父进程为 1
ps -eo pid,ppid,comm | awk '$2==1'

# 3. 僵尸
./scripts/zombie.py &
ps -eo pid,ppid,stat,comm | awk '$3 ~ /^Z/'
# 杀父进程，不是杀僵尸
kill -15 <parent_pid>

# 4. load 高 CPU 不高
# D 状态（IO 等待）、线程阻塞、大量不可中断睡眠；
# 看 vmstat 的 b 列、pidstat、iostat

# 5. -15 vs -9
# -15 可被捕获，进程能清理；-9 不可捕获，可能丢数据

# 6. fd 数量
ls /proc/<pid>/fd | wc -l
lsof -p <pid> | wc -l
```

## 04 磁盘与 IO

```bash
cd 04-磁盘与IO

# 1. 最大 5 个文件
find . -type f -printf '%s %p\n' | sort -rn | head -5

# 2. df vs du
# df 看文件系统整体；du 看目录里文件的实际占用

# 3. 已删除但被占用
lsof +L1

# 4. 五种原因
# 删除未释放 / inode 用尽 / 挂载覆盖 / 保留块 / 稀疏与快照

# 5. util vs await
# %util 是设备忙碌时间比例；await 是单次 IO 平均等待时间
# 高 util 可能是小 IO 打满，高 await 才说明排队严重
```

## 05 网络

```bash
cd 05-网络

# 1. 监听端口
ss -lntp

# 2. 状态码与耗时
curl -s -o /dev/null -w '%{http_code} %{time_total}\n' http://127.0.0.1:8080/

# 3. 端口探测
nc -zv 127.0.0.1 8080

# 4. DNS
dig example.com +short
dig @8.8.8.8 example.com A +short

# 5. 抓包
sudo tcpdump -i lo -nn -c 10 port 8080

# 6. TIME_WAIT 多
# 主动关闭方等待 2MSL，正常；大量短连接会堆积，
# 可调 tcp_tw_reuse，但优先改成长连接/连接池
```

## 06 权限与用户

```bash
cd 06-权限与用户

# 1. 所有人可读
chmod 644 private.txt

# 2. 700 目录
# 属主可读写进入，组和其他人无权限

# 3. umask 027
umask 027
touch ./umask-demo && ls -l ./umask-demo     # -rw-r-----
mkdir ./umask-dir && ls -ld ./umask-dir      # drwxr-x---

# 4. 等价
# chmod 755 == chmod u=rwx,go=rx

# 5. r/w/x
# r 列目录，w 增删改名，x 进入/访问子项

# 6. chmod +x 还是不能执行
findmnt -T . -o TARGET,OPTIONS    # 看是否 noexec
```

## 07 服务与定时

```bash
cd 07-服务与定时

sudo cp systemd/practice.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now practice
systemctl status practice
journalctl -u practice -n 20 --no-pager
sudo systemctl disable --now practice
sudo rm /etc/systemd/system/practice.service
sudo systemctl daemon-reload
```

cron 不执行：`systemctl status cron` → `crontab -l` → 绝对路径 → `/var/log/cron` → 权限与换行。

## 08 归档与传输

```bash
cd 08-归档与传输

tar -czf backup.tar.gz --exclude='*.log' source
tar -tzf backup.tar.gz
rsync -av --dry-run source/ /tmp/rsync-test/
rsync -av source/ /tmp/rsync-test/       # 内容
rsync -av source  /tmp/rsync-test2/      # 目录本身
rm source/a.txt
rsync -av --delete source/ /tmp/rsync-test/
```

## 每组一句话

- 01：路径、inode、权限，三层分开看；
- 02：先筛再排再计数，管道顺序决定结果；
- 03：先看状态，再决定信号；
- 04：df 看文件系统，du 看目录；
- 05：端口 → 连通 → 应用，逐层排除；
- 06：目录的 x 决定能不能穿过；
- 07：改 unit 必 daemon-reload，cron 用绝对路径；
- 08：tar 的 f 在最后，rsync 看末尾斜杠。
