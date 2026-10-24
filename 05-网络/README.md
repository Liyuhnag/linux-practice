# 05 网络

`ss` `ip` `curl` `nc` `dig` `ping` `traceroute` `tcpdump` `lsof -i`

## 练习

### 1. 本机网络

```bash
ip a
ip route
ss -lntp                       # 监听中的 TCP 端口与进程
ss -s                          # 连接状态汇总
ss -ant state time-wait | wc -l
```

`ss` 是 `netstat` 的替代，内核里直接取，比 `netstat` 快；`-p` 需要 root 才能看到别人的进程。

### 2. 起服务、访问它

```bash
python3 -m http.server 8080 &
curl -v http://127.0.0.1:8080/
curl -s -o /dev/null -w '%{http_code} %{time_total}\n' http://127.0.0.1:8080/
curl -I http://127.0.0.1:8080/
```

`curl -v` 的输出分几段：DNS 解析、TCP 连接、TLS 握手、请求、响应。卡在哪一段，问题就在哪一层。

### 3. 端口探测

```bash
nc -zv 127.0.0.1 8080
nc -zv 127.0.0.1 9999
ss -lntp | grep 8080
```

### 4. DNS

```bash
dig example.com +short
dig example.com A
dig @8.8.8.8 example.com +short
getent hosts example.com       # 按 /etc/nsswitch.conf 的顺序
cat /etc/resolv.conf
```

### 5. 抓包

```bash
sudo tcpdump -i lo -c 10 port 8080 -nn
sudo tcpdump -i any -nn 'tcp[tcpflags] & tcp-syn != 0'
```

看懂三次握手：`SYN` → `SYN,ACK` → `ACK`。只有 `SYN` 没有回包，通常是防火墙或端口没开。

## 小故障

`curl http://127.0.0.1:9999` 卡住或报 `Connection refused`。按顺序判断：

1. 端口有没有人监听（`ss -lntp`）
2. 本机能不能连（`nc -zv`）
3. 是不是防火墙（`iptables -L` / `firewall-cmd --list-all`）
4. 服务是不是只监听了 `127.0.0.1`（不是 `0.0.0.0`）

## 自测

1. 列出所有监听端口和进程
2. 用 curl 只看状态码和耗时
3. 判断 8080 有没有服务
4. 查一个域名的 A 记录，并指定 DNS 服务器
5. 抓 10 个包，指出 SYN/ACK
6. `TIME_WAIT` 很多说明什么

## 常用状态码

- `TIME_WAIT`：主动关闭方等待 2MSL，正常现象，多了可以调 `tcp_tw_reuse`
- `CLOSE_WAIT`：**被动关闭方没有 close()**，通常是应用没处理，属于 bug
- `SYN_RECV`：收到 SYN 但没完成握手，可能有 SYN flood

## Linux / macOS 差异

- macOS 没有 `ss`、`ip`，用 `netstat -an`、`ifconfig`、`lsof -i`；
- 网卡名不同：Linux `eth0`/`ens33`，macOS `en0`；
- `tcpdump -i any` 在 macOS 上不支持，用具体接口。
