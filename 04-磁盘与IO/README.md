# 04 磁盘与 IO

`df` `du` `ls` `lsof` `stat` `find` `iostat` `lsblk` `iotop`

## 样本

- `sparse.img`：逻辑 1 GiB，实际只占几十 KiB 的**稀疏文件**
- `small-files/`：300 个小文件

## 练习

### 1. 看容量

```bash
df -h
df -h .
df -i .                 # inode 使用率
du -sh ./*
du -xh --max-depth=1 . | sort -h
lsblk                   # 块设备与挂载点
```

`df` 统计**文件系统**，`du` 统计**目录里的文件**。两者对不上，是排障的重点。

### 2. 逻辑大小 vs 实际占用

```bash
ls -lh sparse.img
du -h sparse.img
stat -c '%s bytes, %b blocks' sparse.img
du --apparent-size -h sparse.img
```

`%s` 是逻辑大小，`%b` 是实际占用的 512 字节块。稀疏文件两者的差距可能上千倍。

### 3. 找大文件与大目录

```bash
find . -type f -size +1M -exec ls -lh {} +
du -ah . | sort -rh | head
```

### 4. 谁占着文件

```bash
lsof +L1                       # 链接数为 0 但被打开（已删除未释放）
lsof -p <pid> | head
lsof | wc -l
```

### 5. IO 观察

```bash
iostat -xz 1 3
iotop -o                       # 需要 root
```

看 `%util`、`await`、`r/s`、`w/s`。`%util` 接近 100 不等于一定饱和，还要看 `await` 和队列深度。

## 小故障

复制/下载一个文件后，`ls` 显示 1G，但 `du` 只有几十 K。

用 `stat` 验证它是不是稀疏文件，再想：`cp` 默认会不会保留稀疏？（GNU cp 需要 `--sparse=always`）

## 自测

1. 找出仓库里最大的 5 个文件
2. 说明 `df` 和 `du` 的区别
3. 找出已删除但被进程占用的文件
4. `df` 显示 100% 但 `du` 不大，列出至少 4 种原因
5. 解释 `iostat` 的 `%util` 与 `await`

## df 满了但 du 不大：五种原因

1. 已删除但被进程占用（`lsof +L1`）
2. inode 用尽（`df -i`，小文件太多）
3. 挂载覆盖（新分区盖住了旧目录，`findmnt`）
4. 文件系统保留块（ext4 默认 5%）
5. 稀疏文件 / 快照 / 镜像层

## Linux / macOS 差异

- `lsblk`、`iotop`、`iostat -x` 在 macOS 不可用或参数不同；
- `du -x` 两者都有，语义接近；
- APFS 下 `df -i` 意义有限。
