#!/usr/bin/env python3
"""模拟应用：打开一次日志文件，之后一直追加。"""
import sys
import time

path = sys.argv[1] if len(sys.argv) > 1 else "app.log"
f = open(path, "a", buffering=1, encoding="utf-8")
while True:
    f.write(time.strftime("%F %T") + " tick\n")
    f.flush()
    time.sleep(1)
