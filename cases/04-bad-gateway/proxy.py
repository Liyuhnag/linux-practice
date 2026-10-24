#!/usr/bin/env python3
"""一个极简反向代理：18081 -> 18082，上游连不上就返回 502。"""
import socket
import threading
import time

LISTEN = ("127.0.0.1", 18081)
UPSTREAM = ("127.0.0.1", 18082)
LOG = "proxy.log"


def log(msg):
    with open(LOG, "a", encoding="utf-8") as f:
        f.write(f"{time.strftime('%F %T')} {msg}\n")


def handle(conn):
    try:
        conn.settimeout(2)
        data = conn.recv(65536)
        if not data:
            return
        try:
            up = socket.create_connection(UPSTREAM, timeout=1)
            up.sendall(data)
            while True:
                chunk = up.recv(65536)
                if not chunk:
                    break
                conn.sendall(chunk)
            up.close()
            log("proxied ok")
        except Exception as exc:  # noqa: BLE001
            body = b"502 Bad Gateway\n"
            conn.sendall(
                b"HTTP/1.1 502 Bad Gateway\r\n"
                b"Content-Type: text/plain\r\n"
                b"Content-Length: %d\r\n"
                b"Connection: close\r\n\r\n" % len(body) + body
            )
            log(f"upstream error: {exc!r}")
    finally:
        conn.close()


def main():
    srv = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    srv.bind(LISTEN)
    srv.listen(16)
    log("proxy listening on 18081")
    while True:
        conn, _ = srv.accept()
        threading.Thread(target=handle, args=(conn,), daemon=True).start()


if __name__ == "__main__":
    main()
