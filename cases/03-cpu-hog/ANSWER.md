# 参考答案 03

## 1. 先看整体

```bash
uptime
nproc
```

`load average` 的 1 分钟值接近或超过核数，说明有进程在排队。

## 2. 找进程

```bash
top -b -n1 -o %CPU | head -15
# 或
ps -eo pid,ppid,stat,%cpu,%mem,args --sort=-%cpu | head
```

会看到 `report-worker`，CPU 接近 100%。

## 3. 确认它是什么

```bash
pid=$(pgrep -f report-worker | head -1)
ps -fp "$pid"
ls -l /proc/$pid/exe
tr '\0' ' ' < /proc/$pid/cmdline; echo
```

`exe` 指向 `cases/03-cpu-hog/bin/report-worker`，确认不是系统进程。

## 4. 结束

```bash
kill -15 "$pid"
sleep 1
pgrep -f report-worker || echo "已退出"
```

如果 `-15` 不生效（比如它忽略 TERM），再 `kill -9`。

## 5. 验证

```bash
uptime
```

负载不会立刻归零，1 分钟平均值需要一两分钟才降下来。

## 考点

- `top -b -n1` 适合脚本/一次性快照；
- `ps --sort=-%cpu` 比 `top` 好写；
- `/proc/<pid>/exe` 和 `cmdline` 能确认进程身份；
- 先 `-15`，不行再 `-9`。
