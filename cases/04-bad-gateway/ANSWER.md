# 参考答案 04

## 1. 先看客户端

```bash
curl -v http://127.0.0.1:18081/
```

`-v` 里会看到 `< HTTP/1.1 502 Bad Gateway`，说明请求到了网关，是网关返回的 502。

## 2. 看谁在监听

```bash
ss -lntp | grep -E '18081|18082'
lsof -nP -iTCP:18081 -sTCP:LISTEN
lsof -nP -iTCP:18082 -sTCP:LISTEN
```

只看到 18081，**18082 没人监听**。

## 3. 看网关日志

```bash
tail -n 20 proxy.log
```

类似：

```text
2026-10-24 21:00:03 upstream error: ConnectionRefusedError(111, 'Connection refused')
```

## 4. 恢复上游

```bash
python3 upstream.py &
echo $! > .upstream.pid
sleep 1
curl -s http://127.0.0.1:18081/
# upstream ok
```

## 5. 收尾

```bash
bash clean.sh
```

## 考点

- 502 表示“网关收到了请求，但上游出问题”，不是客户端问题；
- `curl -v` 能区分“连不上网关”和“网关了但上游错”；
- `ss -lntp` 一次看两个端口，最快确认上游没起；
- 看代理/网关日志，别猜。
