# 参考答案 02

## 1. 看链接，而不是看内容

```bash
cd cases/02-broken-config
ls -l app/
```

会看到：

```text
lrwxr-xr-x ... config.yml -> ../config/app.yml
```

`cat` 失败、`ls` 能看到，说明**链接本身在，目标不在**。

## 2. 确认断链

```bash
readlink app/config.yml
readlink -f app/config.yml
readlink -e app/config.yml || echo "目标不存在"
test -e app/config.yml || echo "broken"
```

`readlink -e` 要求整条路径真实存在，断链时无输出、退出码非 0。

## 3. 看每一级目录

```bash
namei -l "$PWD/app/config.yml"
```

输出会显示 `config/` 这一级不存在，或者权限不对。

## 4. 修复

目标文件压根没创建，补上：

```bash
mkdir -p config
printf 'port=8080\n' > config/app.yml
./app/run.sh
# config loaded: port=8080
```

或者重新指向正确路径：

```bash
ln -sfn /path/to/real/config.yml app/config.yml
```

## 5. 收尾

```bash
bash clean.sh
```

## 考点

- `ls -l` 看到 `l` 和 `->`，就要想到软链接；
- `readlink -f` 允许最后一段不存在，`-e` 要求全部存在；
- `namei -l` 能一眼看出断在哪一级；
- 相对软链接的 `..` 是相对于**链接所在目录**解析的。
