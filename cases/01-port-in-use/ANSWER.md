# 参考答案 01

## 1. 确认谁占了端口

```bash
ss -lntp | grep 18080
# 或
lsof -nP -iTCP:18080 -sTCP:LISTEN
```

会看到一个 `python3` 进程，PID 不是你的服务。

## 2. 看它是什么

```bash
ps -fp <pid>
cat /proc/<pid>/cmdline | tr '\0' ' '
```

`cmdline` 里是 `python3 -m http.server 18080 --bind 127.0.0.1`，说明是上一次练习留下的。

## 3. 结束它

```bash
kill -15 <pid>
# 还在就 kill -9 <pid>
```

用 `lsof -t` 的写法更省事：

```bash
lsof -t -iTCP:18080 -sTCP:LISTEN | xargs -r kill -15
```

## 4. 启动并验证

```bash
./run.sh &          # 或另开一个终端
sleep 1
curl -s http://127.0.0.1:18080/
# ok
```

## 5. 收尾

```bash
bash clean.sh
kill %1 2>/dev/null || true
```

## 考点

- `ss -lntp` 的 `-p` 要看进程，需要权限；
- `lsof -t` 只出 PID，适合接 `xargs`；
- 先 `-15` 再 `-9`，不要上来就 `-9`。
