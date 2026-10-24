# 真实案例演练

五个小事故，都是“线上常见、命令能解决”的类型。

## 玩法

1. 进入某个案例目录；
2. **先只读 `ticket.md`**，把它当成同事发给你的工单；
3. 自己上机排查，允许用 `ps`、`ss`、`lsof`、`find`、`tail`、`curl` 等；
4. 排完再打开 `ANSWER.md` 对答案；
5. 收尾：`bash clean.sh`。

每个案例都有 `inject.sh` 负责“制造故障”，`clean.sh` 负责“恢复现场”。**不要在生产机跑**，这些脚本会起进程、占端口、移动日志文件。

## 案例列表

| 案例 | 现象 | 考什么 |
| :--- | :--- | :--- |
| `01-port-in-use` | 服务启动报端口被占用 | `ss`、`lsof`、`kill`、`xargs` |
| `02-broken-config` | 服务说配置文件不存在 | `ls -l`、`readlink`、`namei` |
| `03-cpu-hog` | CPU 飙高、机器卡 | `top`、`ps`、`/proc`、信号 |
| `04-bad-gateway` | 接口返回 502 | `curl -v`、`ss`、日志、上游 |
| `05-log-stale` | 日志文件不更新 | `lsof`、`/proc/<pid>/fd`、inode |

## 建议

- 每个案例限时 10 分钟；
- 先说“我下一步要查什么”，再敲命令；
- 排不出来就看 `ANSWER.md` 的第一段，不要一次看完。
