# Yaklang ZIP 库使用文档

## 目录
- [基础功能](#基础功能)
- [高级功能](#高级功能)
- [配置选项](#配置选项)
- [使用示例](#使用示例)

## 基础功能

### 1. 压缩功能

#### zip.CompressRaw(map) - 内存压缩
将内存中的数据压缩为 ZIP 格式的字节数组。

```yak
zipBytes = zip.CompressRaw({
    "a.txt": "Content of a.txt",
    "b.txt": "Content of b.txt",
})~
```

#### zip.Compress(zipFile, files...) - 文件压缩
将文件或目录压缩到 ZIP 文件。

```yak
zip.Compress("output.zip", "file1.txt", "file2.txt", "dir/")~
```

### 2. 解压功能

#### zip.Decompress(zipFile, destDir) - 解压文件
解压 ZIP 文件到指定目录。

```yak
zip.Decompress("archive.zip", "./output/")~
```

### 3. 遍历功能

#### zip.Recursive(zipFile, callback) - 遍历 ZIP 文件
遍历 ZIP 文件中的所有文件和目录。

```yak
zip.Recursive("archive.zip", (isDir, pathName, info) => {
    println("File:", pathName, "Size:", info.Size())
})~
```

#### zip.RecursiveFromRaw(rawBytes, callback) - 遍历原始数据
从原始字节数据遍历 ZIP 内容。

```yak
raw = file.ReadFile("archive.zip")~
zip.RecursiveFromRaw(raw, (isDir, pathName, info) => {
    println(pathName)
})~
```

## 高级功能

### 1. Grep 搜索功能

#### zip.GrepRegexp(zipFile, pattern, opts...) - 正则表达式搜索
使用正则表达式在 ZIP 文件中搜索内容。

```yak
results = zip.GrepRegexp("archive.zip", "ERROR.*", zip.grepLimit(10))~
for result in results {
    println(result.FileName, ":", result.LineNumber, "-", result.Line)
}
```

#### zip.GrepSubString(zipFile, substring, opts...) - 子字符串搜索
在 ZIP 文件中搜索子字符串（默认不区分大小写）。

```yak
// 不区分大小写搜索
results = zip.GrepSubString("archive.zip", "error")~

// 区分大小写搜索
results = zip.GrepSubString("archive.zip", "ERROR", zip.grepCaseSensitive())~
```

#### zip.GrepRawRegexp(rawData, pattern, opts...) - 原始数据正则搜索
从原始字节数据中使用正则表达式搜索。

```yak
raw = file.ReadFile("archive.zip")~
results = zip.GrepRawRegexp(raw, `func\s+\w+`, zip.grepContextLine(2))~
```

#### zip.GrepRawSubString(rawData, substring, opts...) - 原始数据子串搜索
从原始字节数据中搜索子字符串。

```yak
raw = file.ReadFile("archive.zip")~
results = zip.GrepRawSubString(raw, "TODO", zip.grepLimit(5))~
```

### 2. 文件提取功能

#### zip.ExtractFile(zipFile, fileName) - 提取单个文件
从 ZIP 文件中提取单个文件的内容。

```yak
content = zip.ExtractFile("archive.zip", "config.json")~
println(content)
```

#### zip.ExtractFileFromRaw(rawData, fileName) - 从原始数据提取单个文件
从原始字节数据中提取单个文件。

```yak
raw = file.ReadFile("archive.zip")~
content = zip.ExtractFileFromRaw(raw, "README.md")~
```

#### zip.ExtractFiles(zipFile, fileNames) - 批量提取文件（并发）
并发提取多个文件。

```yak
results = zip.ExtractFiles("archive.zip", ["file1.txt", "file2.txt"])~
for result in results {
    if result.Error == nil {
        println(result.FileName, ":", len(result.Content), "bytes")
    }
}
```

#### zip.ExtractFilesFromRaw(rawData, fileNames) - 从原始数据批量提取
从原始字节数据并发提取多个文件。

```yak
raw = file.ReadFile("archive.zip")~
results = zip.ExtractFilesFromRaw(raw, ["a.txt", "b.txt"])~
```

#### zip.ExtractByPattern(zipFile, pattern) - 模式匹配提取
根据文件名模式提取文件（支持通配符）。

```yak
// 提取所有 .txt 文件
results = zip.ExtractByPattern("archive.zip", "*.txt")~

// 提取 src/ 目录下的所有文件
results = zip.ExtractByPattern("archive.zip", "src/*")~

// 提取所有文件
results = zip.ExtractByPattern("archive.zip", "*")~
```

#### zip.ExtractByPatternFromRaw(rawData, pattern) - 从原始数据模式提取
从原始字节数据根据模式提取文件。

```yak
raw = file.ReadFile("archive.zip")~
results = zip.ExtractByPatternFromRaw(raw, "*.json")~
```

## 配置选项

### Grep 配置选项

#### zip.grepLimit(n) - 限制结果数量
限制返回的搜索结果数量。

```yak
results = zip.GrepRegexp("archive.zip", "error", zip.grepLimit(10))~
```

#### zip.grepContextLine(n) - 设置上下文行数
设置匹配行的上下文行数（前后各 n 行）。

```yak
results = zip.GrepRegexp("archive.zip", "ERROR", zip.grepContextLine(3))~
for result in results {
    // 显示前置上下文
    for line in result.ContextBefore {
        println("  ", line)
    }
    // 显示匹配行
    println("> ", result.Line)
    // 显示后置上下文
    for line in result.ContextAfter {
        println("  ", line)
    }
}
```

#### zip.grepCaseSensitive() - 区分大小写
启用区分大小写的搜索（默认不区分）。

```yak
results = zip.GrepSubString("archive.zip", "ERROR", zip.grepCaseSensitive())~
```

## 使用示例

### 示例 1: 日志分析工作流

```yak
// 1. 搜索错误日志
errorResults = zip.GrepRegexp("logs.zip", `\[ERROR\]`, zip.grepContextLine(2))~
println("找到", len(errorResults), "个错误")

// 2. 提取包含错误的日志文件
logFiles = []
for result in errorResults {
    if result.FileName not in logFiles {
        logFiles = append(logFiles, result.FileName)
    }
}

// 3. 提取完整日志文件进行分析
logs = zip.ExtractFiles("logs.zip", logFiles)~
for log in logs {
    if log.Error == nil {
        // 分析日志内容
        println("分析文件:", log.FileName)
    }
}
```

### 示例 2: 代码审计

```yak
// 1. 搜索敏感函数调用
results = zip.GrepRegexp("code.zip", `eval\s*\(|exec\s*\(`)~
println("发现", len(results), "个潜在安全问题")

// 2. 提取所有代码文件
codeFiles = zip.ExtractByPattern("code.zip", "*.yak")~

// 3. 分析代码指标
totalLines = 0
for code in codeFiles {
    if code.Error == nil {
        lines = str.Split(code.Content, "\n")
        totalLines += len(lines)
    }
}
println("总代码行数:", totalLines)
```

### 示例 3: Grep + Extract 组合应用

```yak
// 1. 使用 Grep 查找包含特定内容的文件
results = zip.GrepRegexp("project.zip", `func\s+\w+`)~
filesWithFunctions = {}
for result in results {
    filesWithFunctions[result.FileName] = true
}

// 2. 提取这些文件的完整内容
filesToExtract = []
for filename, _ in filesWithFunctions {
    filesToExtract = append(filesToExtract, filename)
}

files = zip.ExtractFiles("project.zip", filesToExtract)~

// 3. 分析提取的文件
for file in files {
    if file.Error == nil {
        println("分析文件:", file.FileName)
        // 进行详细分析...
    }
}
```

### 示例 4: 配置文件管理

```yak
// 1. 提取所有配置文件
configs = zip.ExtractByPattern("app.zip", "*.json")~

// 2. 检查敏感配置
sensitiveKeywords = ["password", "secret", "key"]
for keyword in sensitiveKeywords {
    results = zip.GrepSubString("app.zip", keyword)~
    if len(results) > 0 {
        println("警告：发现敏感关键词:", keyword)
        for result in results {
            println("  ", result.FileName, ":", result.LineNumber)
        }
    }
}
```

## 性能特性

### 并发处理
- `ExtractFiles` 和 `ExtractByPattern` 使用并发提取，提高处理速度
- 并发数自动根据 CPU 核心数调整，最多 8 个并发
- 适合处理大量文件的场景

### 内存效率
- 支持原始数据操作，无需写入临时文件
- 流式处理，减少内存占用
- 支持大文件的增量读取

## 注意事项

1. **错误处理**: 所有函数都返回错误，建议使用 `~` 操作符或 `try-catch` 处理
2. **路径安全**: 解压时会检查路径安全，防止路径穿越攻击
3. **编码支持**: 支持 UTF-8 编码的文件内容
4. **通配符**: `*` 表示任意字符，支持前缀、后缀和中间匹配

## 参考文档

- [zip-practice.yak](./zip-practice.yak) - 基础功能练习
- [zip-advance.yak](./zip-advance.yak) - 高级功能实战
- [zip.yak](../../yaklang/common/yak/yaktest/mustpass/files/zip.yak) - 完整测试用例
