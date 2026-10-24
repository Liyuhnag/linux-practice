# 参考答案 05

## 1. 确认现象

```bash
tail -F app.log
# 一直没有新行
ls -l app.log app.log.1
```

`app.log` 是空的、时间不再变化，`app.log.1` 却在长大。

## 2. 找到进程

```bash
pgrep -af logger.py
pid=$(cat .pid)
```

## 3. 看它打开的是哪个文件

```bash
lsof -p "$pid" | grep -E 'app\.log'
ls -l /proc/$pid/fd | grep app
```

会看到 fd 指向 `app.log.1`，而不是新的 `app.log`。

原因：应用启动时 `open("app.log")` 拿到的是一个 inode；`mv` 只改了目录项，fd 还指着旧 inode。新建的 `app.log` 是另一个 inode，应用根本不知道。

## 4. 修复

让应用重新打开文件：

```bash
kill -15 "$pid"
python3 logger.py app.log &
echo $! > .pid
tail -F app.log
```

生产上更规范的做法：

- 应用支持 `SIGHUP` 或 `reload`，日志轮转后通知它重开；
- logrotate 用 `copytruncate`（复制后清空原文件），避免 inode 变化；
- 或者用支持 reopen 的日志库。

## 5. 收尾

```bash
bash clean.sh
```

## 考点

- `tail -f` 跟的是 fd，轮转后不动；`tail -F` 按文件名重开；
- `lsof -p` 和 `/proc/<pid>/fd` 能看出进程实际写的是哪个 inode；
- “文件名”和“文件”不是一回事。
