# 08 归档与传输

`tar` `gzip` `zip` `unzip` `rsync` `scp`

## 样本

`./bin/setup.sh 08` 会生成：

```text
source/
├── a.txt
├── b.log
├── empty/        # 空目录
└── sub/
    └── c.txt
```

## 练习

### 1. 打包与解包

```bash
tar -czf backup.tar.gz source
tar -tzf backup.tar.gz          # 不解压，只看内容
mkdir -p /tmp/extract && tar -xzf backup.tar.gz -C /tmp/extract
```

参数含义：`c` 创建、`x` 解压、`t` 列出、`z` gzip、`f` 后面跟文件名。`f` 必须在最后（后面紧跟文件名）。

### 2. 排除

```bash
tar -czf backup-no-log.tar.gz --exclude='*.log' source
tar -tzf backup-no-log.tar.gz
```

GNU tar 的 `--exclude` 建议放在源路径前面；放在后面有时不生效，这是常见坑。

### 3. rsync

```bash
rsync -av source/ /tmp/rsync-test/
rsync -av source  /tmp/rsync-test2/
```

- `source/`：同步**目录里的内容**，目标里直接出现 `a.txt`
- `source`：同步**目录本身**，目标里出现 `source/a.txt`

先 `--dry-run` 看会做什么：

```bash
rsync -av --dry-run --delete source/ /tmp/rsync-test/
```

### 4. 同步删除

```bash
rm source/a.txt
rsync -av --delete source/ /tmp/rsync-test/
ls /tmp/rsync-test/
```

`--delete` 会让目标端和源端完全一致，**删之前一定先 `--dry-run`**。

### 5. scp

```bash
scp source/a.txt localhost:/tmp/a.txt
scp -r source localhost:/tmp/source-copy
```

## 小故障

`tar -xzf` 报 `not in gzip format`。先用 `file` 看真实格式：

```bash
file backup.tar.gz
```

可能是被重命名过的 `.zip`，或者其实是未压缩的 tar。扩展名不代表格式。

## 自测

1. 打包 `source` 并排除 `.log`
2. 不解压，列出包里的文件
3. 用 rsync 同步到 `/tmp`，删掉源文件再同步，观察 `--delete`
4. 解释 `source/` 和 `source` 的区别
5. `tar -xvzf` 各参数含义
6. `rsync` 比 `scp` 适合什么场景

## 常见坑

- `tar` 的 `f` 后面必须紧跟文件名；
- `rsync` 的末尾斜杠决定“内容”还是“目录本身”；
- `scp` 传大量小文件慢，用 `rsync` 或先打包；
- 跨机器用 `rsync -e ssh`，加 `-z` 压缩，加 `--partial` 断点续传。

## Linux / macOS 差异

- Linux 通常是 GNU tar；macOS 是 bsdtar，`--exclude` 位置更宽松；
- macOS 自带 rsync 版本很老（2.6.9），部分参数不支持；
- 想统一：`brew install gnu-tar coreutils`，命令加 `g` 前缀。
