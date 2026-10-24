# Linux 命令练习场

八组命令、八个目录，每组都有**可重建的样本**和一组练习。目标不是背参数，而是**遇到场景能想起用哪条命令，看得懂输出**。

面向 Linux 服务器（GNU 工具链）。macOS 上也能跑大部分，差异写在每篇末尾。

## 快速开始

```bash
git clone https://github.com/Liyuhnag/linux-practice.git
cd linux-practice
./bin/setup.sh          # 生成所有样本（约 3 秒）
```

然后从 `01-文件与目录` 开始：

```bash
cd 01-文件与目录
cat README.md
ls -la
```

## 目录

| 目录 | 命令 | 核心问题 |
| :--- | :--- | :--- |
| `01-文件与目录` | `ls find stat ln readlink` | 文件在哪、是不是同一个、链到哪 |
| `02-查看与文本` | `cat less head tail grep sed awk cut sort uniq` | 怎么在日志里找到那一条 |
| `03-进程与系统` | `ps top pgrep kill free vmstat uptime` | 谁在吃资源、怎么安全地停 |
| `04-磁盘与IO` | `df du lsof iostat lsblk find` | 空间去哪了、谁占着文件 |
| `05-网络` | `ss ip curl nc dig tcpdump` | 端口通不通、卡在哪一步 |
| `06-权限与用户` | `chmod chown umask namei id setfacl` | 为什么读不到、谁能进 |
| `07-服务与定时` | `systemctl journalctl crontab logrotate` | 服务为什么起不来 |
| `08-归档与传输` | `tar rsync scp zip` | 怎么打包、怎么增量同步 |

## 每篇的结构

1. **命令**：本篇涉及哪些；
2. **样本**：`setup.sh` 生成了什么；
3. **练习**：5 组，每组一个具体动作；
4. **小故障**：一个可复现的问题，先猜再验证；
5. **自测**：不看答案手写命令；
6. **Linux / macOS 差异**。

参考答案在 [`SOLUTIONS.md`](SOLUTIONS.md)。

## 真实案例

`cases/` 里有五个可复现的小事故，每个都有工单、注入脚本、清理脚本和答案：

| 案例 | 现象 | 考什么 |
| :--- | :--- | :--- |
| 01-port-in-use | 服务报端口被占用 | ss、lsof、kill |
| 02-broken-config | 配置说找不到 | ls -l、readlink、namei |
| 03-cpu-hog | CPU 95% | top、ps、/proc |
| 04-bad-gateway | 接口 502 | curl -v、ss、日志 |
| 05-log-stale | 日志不更新 | lsof、/proc/pid/fd |

```bash
cd cases/01-port-in-use
cat ticket.md        # 先只看工单
bash inject.sh       # 制造故障
# 开始排查……
bash clean.sh        # 收尾
```

先别翻 `ANSWER.md`。

## 重置

练坏了不用慌，样本都是生成的：

```bash
./bin/setup.sh              # 重建全部
./bin/setup.sh 04           # 只重建 04
```

## 三天路径

| 天 | 目录 | 大概耗时 |
| :--- | :--- | :--- |
| 第 1 天 | 01、02、04 | 3–4 小时 |
| 第 2 天 | 03、06 | 2–3 小时 |
| 第 3 天 | 05、07、08 + 自测 | 3 小时 |

## 环境要求

- Linux（GNU coreutils、util-linux、procps、iproute2、tar、rsync）
- `bash`、`python3`（只用于生成样本，不参与练习）
- Debian/Ubuntu 装依赖：`sudo apt install -y procps util-linux iproute2 rsyslog lsof iotop sysstat`
- RHEL/Rocky：`sudo yum install -y procps-ng util-linux iproute lsof iotop sysstat`

## 约定

- 所有 `find` / `grep` / `sed` / `stat` 示例都按 **GNU 版**写；
- 需要 root 的步骤会标 `sudo`，其余都在仓库目录内完成，不动系统文件；
- 破坏性练习（`kill`、`rm`、`chmod`）只作用于本仓库生成的样本。

## License

MIT
