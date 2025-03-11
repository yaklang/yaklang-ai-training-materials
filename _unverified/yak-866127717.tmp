# Yaklang 中的 Git 仓库操作指南

Yaklang 提供了对 Git 仓库的基本操作支持，包括克隆、遍历提交记录和引用等功能。以下是如何使用 `git` 模块来完成这些任务的详细说明。

## 克隆远程仓库

要从远程服务器克隆一个 Git 仓库到本地，可以使用 `git.Clone` 函数。这个函数接受两个参数：目标 URL 和本地目录路径。

```yak
targetUrl = f`${VULINBOX}/gitserver/website-repository.git/`
dump(targetUrl)
localReposDir = file.Join(os.TempDir(), str.RandStr(16))
defer os.RemoveAll(localReposDir)
git.Clone(targetUrl, localReposDir)~
```

### 示例解释
- **targetUrl**: 远程仓库的 URL。
- **localReposDir**: 本地存储仓库的临时目录，通过 `os.TempDir()` 和随机字符串生成。
- **defer os.RemoveAll(localReposDir)**: 确保在脚本结束时删除临时目录，释放资源。
- **git.Clone**: 执行克隆操作，波浪线 (`~`) 表示忽略错误（如果有）。

## 读取文件内容

克隆完成后，可以通过标准文件操作读取特定文件的内容。

```yak
ret := string(file.ReadFile(file.Join(localReposDir, "index.html"))~)
dump(ret)
assert `<title>AAABBBCCC</title>` in ret
```

### 示例解释
- **file.ReadFile**: 读取指定路径的文件内容。
- **string()**: 将字节切片转换为字符串。
- **assert**: 断言文件内容包含特定字符串。

## 遍历提交记录和引用

可以使用 `git.IterateCommit` 来遍历仓库中的提交记录和引用。

```yak
count = 0
refCount = 0
die(git.IterateCommit(localReposDir, git.handleCommit(i => {
    count++
}), git.handleReference(i => {
    refCount ++
})))
dump(count, refCount)
if count < 3 { die("COMMIT IS TOO LESS") }
if refCount < 3 { die("REF IS TOO LESS") }
```

### 示例解释
- **git.IterateCommit**: 遍历仓库中的提交记录和引用。
- **git.handleCommit**: 处理每个提交记录的回调函数。
- **git.handleReference**: 处理每个引用的回调函数。
- **die**: 如果提交或引用数量不足，抛出错误并终止脚本。

## 处理多个仓库

如果需要处理多个仓库，可以重复上述步骤。

```yak
targetUrl = f`${VULINBOX}/gitserver/sca-testcase.git/`
dump(targetUrl)
localReposDir = file.Join(os.TempDir(), str.RandStr(16))
os.RemoveAll(localReposDir)
git.Clone(targetUrl, localReposDir)~
ret := string(file.ReadFile(file.Join(localReposDir, `testdata`,`node_npm`,`positive_file`,`package.json`))~)
dump(ret)
assert `unopinionated, minimalist web framework` in ret
```

### 示例解释
- **重复克隆和读取文件**: 对另一个仓库执行相同的操作，确保文件内容符合预期。

## 总结

以上示例展示了如何在 Yaklang 中使用 `git` 模块来克隆远程仓库、读取文件内容以及遍历提交记录和引用。这些功能对于自动化代码审计和安全测试非常有用。希望这份文档能帮助你更好地理解和使用 Yaklang 的 Git 功能。

