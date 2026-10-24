# 01 文件与目录

`ls` `find` `stat` `ln` `readlink` `namei` `file` `cp` `mv` `rm`

## 样本

`./bin/setup.sh 01` 会生成：

- 普通文件：`original.txt`、`project/**`
- **硬链接**：`hardlink.txt`（与 `original.txt` 同 inode）
- **软链接**：`link-to-main`（有效）、`broken-link`（断链）、`relative-link`（相对路径、目标不存在）
- 特殊名字：`.hidden-file`、`with space.txt`、`-dash-file.txt`、`config.yaml `（**末尾有空格**）
- `many-files/`：120 个文件 + 3 个不同时间戳的 `old-*.txt`
- `empty-dir/`：空目录

## 练习

### 1. 读懂 ls -l

```bash
ls -li
```

回答：第二列是什么？`original.txt` 和 `hardlink.txt` 的 inode 相同吗？

### 2. 硬链接 vs 软链接

```bash
stat -c 'inode=%i links=%h size=%s name=%n' original.txt hardlink.txt
stat -c 'inode=%i links=%h type=%F name=%n' link-to-main broken-link
```

- 硬链接：同 inode，链接数 2，类型都是 `regular file`
- 软链接：**类型是 `symbolic link`**，链接数 1，inode 不同

`stat` 默认看链接本身；想看目标用 `stat -L`。

### 3. 断链

```bash
cat broken-link
readlink broken-link
readlink -f broken-link      # 规范化成绝对路径
readlink -e broken-link      # 目标不存在则无输出、退出码非 0
find . -xtype l              # 找所有断链
```

`readlink -f` 与 `-e` 的区别是面试高频：`-f` 允许最后一段不存在，`-e` 要求全部存在。

### 4. 找文件

```bash
find . -name '*.py'
find . -type f -size +1k
find . -type f -mtime -7
find . -maxdepth 2 -type d
find . -type d -empty
find . -inum "$(stat -c %i original.txt)"     # 按 inode 找
find . -samefile original.txt                  # 找同一个 inode 的其他名字
```

### 5. 特殊文件名

```bash
ls -1 | cat -A                 # 看到末尾空格的 $
cat -- -dash-file.txt          # - 开头
cat "./-dash-file.txt"
cat "with space.txt"
find . -maxdepth 1 -name '*yaml*' -print0 | xargs -0 -n1 printf '%q\n'
```

## 小故障

`broken-link` 指向的文件不存在。如果这是某个服务的配置路径，启动时报的会是 `No such file or directory`，而不是“断链”。

先 `readlink` 找到目标，再决定：重建链接，还是恢复目标文件？

## 自测

1. 找出 7 天内修改过的 `.txt`
2. 证明 `original.txt` 与 `hardlink.txt` 是同一个文件（两种方法）
3. 列出所有断链
4. 读一个以 `-` 开头的文件
5. 找出所有空目录
6. 把 `hardlink.txt` 删掉，`original.txt` 还能读吗？链接数变成几？

## Linux / macOS 差异

| 用途 | Linux | macOS |
| :--- | :--- | :--- |
| `stat` 格式 | `-c 'fmt'` | `-f 'fmt'` |
| 断链 | `find -xtype l` | `find -type l ! -exec test -e {} \;` |
| `readlink -e` | 支持 | 不支持 |
| 文件类型 | `file -b` | `file -b`（可用） |
