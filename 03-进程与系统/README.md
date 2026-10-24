# 03 进程与系统

`ps` `top` `pgrep` `pkill` `kill` `nice` `renice` `uptime` `free` `vmstat` `pidstat`

## 样本

- `scripts/busy.sh [秒]`：吃满一个 CPU 核
- `scripts/sleeper.sh [秒]`：长时间睡眠
- `scripts/zombie.py`：制造一个僵尸进程（子进程退出、父进程不 wait）

## 练习

### 1. 看进程

```bash
ps -eo pid,ppid,stat,%cpu,%mem,etime,comm --sort=-%cpu | head
ps aux | grep -E 'busy|sleeper' | grep -v grep
pgrep -af sleeper
pgrep -P $$                    # 我的子进程
pstree -p $$ 2>/dev/null || ps -ejH | head
```

`STAT`：`R` 运行、`S` 可中断睡眠、`D` 不可中断（IO 等待）、`Z` 僵尸、`+` 前台进程组。

### 2. 制造负载

```bash
./scripts/busy.sh 120 &
./scripts/sleeper.sh 300 &
./scripts/zombie.py &
```

### 3. 观察

```bash
top -b -n 1 | head -20
top -H -p <pid>               # 看线程
uptime                        # load average：1/5/15 分钟
free -m
vmstat 1 3
pidstat -u -p <pid> 1 3       # 需要 sysstat
```

`load average` 高但 CPU 不高，通常是 `D` 状态（IO 等待）或线程阻塞，别只看 CPU。

### 4. 结束进程

```bash
kill -15 <pid>                # SIGTERM：让进程自己清理
kill -9  <pid>                # SIGKILL：内核直接杀，来不及清理
pkill -f sleeper
kill -0 <pid> && echo alive   # 试探，不发信号
```

### 5. 僵尸

```bash
ps -eo pid,ppid,stat,comm | awk '$3 ~ /^Z/'
```

僵尸已经死了，`kill` 它没用；要**杀它的父进程**，或者让父进程 `wait`。父进程退出后，僵尸会被 init/systemd 收养并回收。

## 自测

1. CPU 占用前 5 的进程
2. 所有父进程为 1 的进程
3. 制造并清理一个僵尸，说明为什么 `kill -9` 僵尸无效
4. 看 load average，并解释它高但 CPU 不高可能是什么原因
5. `-15` 和 `-9` 的区别
6. 查看某进程打开了多少文件描述符

## Linux / macOS 差异

| 用途 | Linux | macOS |
| :--- | :--- | :--- |
| 内存 | `free -m` | `vm_stat` / `top` |
| 采样 | `top -b -n1` | `top -l 1` |
| 线程 | `top -H -p PID` | `sample PID` |
| 进程树 | `pstree` | `ps -ejH` |
