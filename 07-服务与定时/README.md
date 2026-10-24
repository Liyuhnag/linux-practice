# 07 服务与定时

`systemctl` `journalctl` `systemd-analyze` `crontab` `logrotate` `log`

## 样本

`./bin/setup.sh 07` 会生成：

- `systemd/practice.service`：一个每 5 秒写一行日志的常驻服务
- `systemd/logrotate-practice.conf`：日志轮转配置示例
- `crontab.example`：每分钟写时间的 cron 示例
- `logs/`：练习目录

## 练习

> 下面用到 `sudo` 的步骤会改动系统服务目录。如果只是练命令、不想动系统，用 systemd 的 **user 模式**（`systemctl --user`），或者只读地看现有服务。

### 1. 只读观察（不需要 sudo）

```bash
systemctl list-units --type=service --state=running | head
systemctl status sshd 2>/dev/null || systemctl status ssh 2>/dev/null
journalctl -u ssh -n 20 --no-pager
journalctl -p err -b --no-pager | tail -20
systemd-analyze blame | head
```

`systemctl status` 里重点看三行：`Loaded`（unit 文件路径、enabled/disabled）、`Active`（running/failed、启动时间）、最后几行日志。

### 2. 安装一个练习服务

```bash
sudo cp systemd/practice.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl start practice
systemctl status practice
journalctl -u practice -f          # 另开终端，Ctrl-C 退出
```

### 3. 常见操作

```bash
sudo systemctl restart practice
sudo systemctl stop practice
sudo systemctl enable practice      # 开机自启
sudo systemctl disable practice
systemctl is-enabled practice
systemctl is-active practice
```

### 4. 日志

```bash
journalctl -u practice --since "10 min ago"
journalctl -u practice -o json-pretty | head -20
journalctl --disk-usage
```

### 5. 定时任务

```bash
crontab -l
crontab -e          # 编辑当前用户的 cron
```

格式：`分 时 日 月 周 命令`。练手可以加一行每分钟的任务：

```cron
* * * * * /bin/date >> /tmp/practice-cron.log 2>&1
```

等两分钟，`tail /tmp/practice-cron.log` 看有没有输出。

排查 cron 不执行，按顺序看：

1. `systemctl status cron` / `crond` 是否在跑
2. `crontab -l` 里有没有这一行
3. 命令用绝对路径（cron 的 PATH 很短）
4. 看 `/var/log/cron` 或 `journalctl -u cron`
5. 脚本有没有执行权限、换行是不是 LF

### 6. 日志轮转

```bash
sudo logrotate -d systemd/logrotate-practice.conf    # dry run，只打印不执行
```

## 小故障

服务 `active (running)`，但业务没反应。按顺序查：

1. `systemctl status` 看是不是刚重启、一直重启（`Restart=always` + 启动即崩 = 循环）
2. `journalctl -u xxx -n 100` 看应用自己的报错
3. `ss -lntp` 看端口有没有起来
4. `systemd-analyze verify` 看 unit 文件有没有语法问题
5. 如果是 `ExecStart` 路径错，`status` 里会写 `status=203/EXEC`

## 自测

1. 写一个每 60 秒执行一次的服务/定时任务
2. 查看它是否加载成功、是否 enabled
3. 停止并卸载
4. 用 `journalctl` 找最近 10 分钟某个 unit 的日志
5. `systemctl restart` 和 `reload` 的区别
6. cron 不执行，列出你的排查顺序

## 常用 unit 字段

```ini
[Unit]
Description=...
After=network.target

[Service]
Type=simple
ExecStart=/path/to/bin
Restart=always
RestartSec=2
User=app
Environment=KEY=VALUE

[Install]
WantedBy=multi-user.target
```

改完 unit 文件必须 `systemctl daemon-reload`，否则改动静默不生效。

## Linux / macOS 差异

- macOS 没有 systemd，用 `launchctl` + `log show`；
- macOS 的 cron 仍然可用，但 Apple 推荐 launchd；
- `journalctl` 在容器里通常不可用（没有 systemd），本地练建议用 VM 或实体机。
