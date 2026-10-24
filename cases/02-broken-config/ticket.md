# 工单 02：服务读不到配置文件

**时间**：2026-10-24 20:30
**现象**：服务启动失败，日志：

```text
open /opt/app/config.yml: No such file or directory
```

**已知**：你 `ls app/` 能看到 `config.yml`，但 `cat` 就是打不开。`app/` 目录下只有这个服务。

**要求**：让 `./app/run.sh` 输出 `config loaded: port=8080`。
