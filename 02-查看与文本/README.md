# 02 查看与文本

`cat` `less` `head` `tail` `grep` `wc` `cut` `sort` `uniq` `awk` `sed` `xargs`

## 样本

- `logs/access.log`：2000 行 Nginx 风格访问日志（状态码含 200/304/404/500/502/504）
- `logs/error.log`：5 行错误日志（含 timeout、connection refused）
- `numbers.csv`：5 行 CSV
- `notes.txt`：10 行文本
- `long-lines.txt`：长行
- `crlf.txt`：Windows 换行

## 练习

### 1. 看

```bash
head -5 logs/access.log
tail -3 logs/access.log
less logs/access.log        # / 搜索、G 末尾、q 退出
wc -l logs/access.log
tail -f logs/access.log     # 另开终端 echo 几行试试，Ctrl-C 退出
```

`tail -f` 跟的是**已打开的文件**；日志轮转后要用 `tail -F`。

### 2. 找

```bash
grep ' 502 ' logs/access.log
grep -c ' 500 ' logs/access.log
grep -A2 -B1 timeout logs/error.log
grep -iE 'error|warn' logs/error.log
grep -v ' 200 ' logs/access.log | head
```

### 3. 统计

```bash
awk '{print $1}' logs/access.log | sort | uniq -c | sort -rn | head
awk '{print $9}' logs/access.log | sort | uniq -c | sort -rn
awk '{s+=$10} END {print s}' logs/access.log
awk '$9 ~ /^5/ {print $1}' logs/access.log | sort | uniq -c | sort -rn | head -3
```

管道顺序很重要：**先筛（`awk`/`grep`），再排（`sort`），再计数（`uniq -c`），最后按次数倒序（`sort -rn`）**。`uniq` 只能合并**相邻**重复行。

### 4. 处理字段

```bash
cut -d, -f1,3 numbers.csv
cut -d' ' -f1,9 logs/access.log | head
sort -t, -k2 -n numbers.csv          # 按第 2 列数字排序
```

### 5. 清理与替换

```bash
tr -d '\r' < crlf.txt > crlf-fixed.txt
sed 's/10\.0\.0\.1/REDACTED/g' logs/access.log | head -3
sed -i.bak 's/502/502_BAD/g' logs/error.log && ls logs/   # -i 前先想清楚要不要备份
```

## 小故障

`logs/access.log` 里有 5xx。找出**哪个 IP 的 5xx 最多**，并说明你的管道每一步在做什么。

## 自测

1. 访问量 Top 3 的 IP
2. 各状态码数量
3. 含 `timeout` 且带上下各 1 行
4. 响应字节总和
5. 去掉 `crlf.txt` 的 `\r` 并存成新文件
6. `uniq -c` 前为什么必须 `sort`

## Linux / macOS 差异

- Linux `grep -P` 可用，BSD 不支持，跨平台用 `-E`；
- Linux `sed -i 's/a/b/'` 直接改；macOS 要 `sed -i '' 's/a/b/'`；
- `awk` 在 Linux 上通常是 gawk，`--version` 可以确认。
