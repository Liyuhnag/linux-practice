# 06 权限与用户

`chmod` `chown` `umask` `namei` `id` `groups` `sudo -l` `setfacl` `getfacl`

## 样本

- `private.txt`：600
- `public.txt`：644
- `restricted/`：700，里面有 `secret.txt`
- `noexec.sh`：644（不可执行）
- `exec.sh`：755
- `shared/`：777

## 练习

### 1. 读权限

```bash
ls -l
stat -c '%A %U:%G %n' *
id
groups
```

`-rw-r--r--`：属主 `rw-`、组 `r--`、其他人 `r--`。
`chmod 644` 和 `chmod u=rw,go=r` 等价。

### 2. 目录的 x 位

```bash
ls -ld restricted
cat restricted/secret.txt        # 自己能进
chmod 600 restricted             # 去掉 x
cd restricted                    # 失败
chmod 700 restricted
```

目录的 `r` 是“能否列目录”，`w` 是“能否增删改名”，`x` 是“能否进入/访问子项”。**没有 `x`，子文件权限再大也读不到。**

### 3. 执行位

```bash
./noexec.sh                      # Permission denied
chmod +x noexec.sh
./noexec.sh
```

### 4. umask

```bash
umask
umask 027 && touch ./umask-demo && ls -l ./umask-demo   # -rw-r-----
umask 022
```

默认权限 = 基准（文件 666、目录 777）减 umask。

### 5. 逐级排查

```bash
namei -l "$PWD/restricted/secret.txt"
```

`namei` 会把每一级目录的权限列出来，一眼看出断在哪。

### 6. ACL

```bash
sudo setfacl -m u:nobody:r public.txt
getfacl public.txt
sudo setfacl -b public.txt
```

## 小故障

`./noexec.sh` 报 `Permission denied`。先看执行位，再看挂载点有没有 `noexec`：

```bash
findmnt -T . -o TARGET,OPTIONS
```

如果挂载选项里有 `noexec`，`chmod +x` 也没用。

## 自测

1. 把 `private.txt` 改成所有人可读
2. 创建 700 目录，说明谁能进
3. `umask 027` 下创建文件和目录，权限各是什么
4. `chmod 755` 与 `chmod u=rwx,go=rx` 是否等价
5. 目录的 `r`、`w`、`x` 分别管什么
6. 为什么 `chmod +x` 之后还是不能执行

## Linux / macOS 差异

- macOS 用 `chmod +a` / `ls -le`，没有 `setfacl`；
- macOS 没有 `namei`，用 `ls -ld` 逐级看；
- SELinux（RHEL/CentOS）下，权限对了还可能被 `getenforce` 挡住。
