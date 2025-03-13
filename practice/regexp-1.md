# Yaklang 中正则练习题

## 基础正则匹配操作详解

### 使用 `re.Match()` 判断模式是否存在

`re.Match()` 函数用于检测文本中是否存在满足特定正则模式的内容，返回布尔值结果。

```yak
// 正则匹配示例：检查文本中是否存在指定模式
raw = `this is text for Hello-World`
result = re.Match(`this is text for .+`/*pattern: string*/, raw)
dump(result) // (bool) true
// 解析：`.+` 匹配一个或多个任意字符，整个模式成功匹配文本内容
```

**成功匹配案例**：上面的例子中，正则模式能完整匹配文本内容，因此返回 `true`

**失败匹配案例**：如果正则模式在文本中找不到匹配项，将返回 `false`

```yak
// 不存在匹配的案例
raw = `this is text for Hello-World`
result = re.Match(`no existed text for .+`/*pattern: string*/, raw)
dump(result) // (bool) false
// 解析：文本中不存在以"no existed text for"开头的内容，因此匹配失败
```

## 文本提取功能

### 使用 `re.Find()` 提取单个匹配结果（无分组）

`re.Find()` 函数返回第一个匹配指定正则模式的文本片段，而不关注正则中的分组。

```yak
// 简单文本提取示例
raw = `this is text for Hello-World`
result = re.Find(raw, `for .+`)
dump(result) // (string) (len=15) "for Hello-World"
// 解析：提取以"for"开头，后跟任意字符的文本片段
```

### 使用 `re.FindAll()` 提取所有匹配结果（无分组）

当需要提取文本中所有符合正则模式的内容时，`re.FindAll()` 函数返回所有匹配项的字符串数组。

```yak
// 提取多行文本中所有匹配项
raw = `this is text for Hello-World
for Foo-Bar
for Me
for You`
result = re.FindAll(raw, `for [^\n]+`)
dump(result)
/**
OUTPUT:

([]string) (len=4 cap=10) {
 (string) (len=15) "for Hello-World",
 (string) (len=11) "for Foo-Bar",
 (string) (len=6) "for Me",
 (string) (len=7) "for You"
}
*/
// 解析：正则 `for [^\n]+` 匹配以"for"开头，后跟一个或多个非换行符的内容
// [^\n]+ 表示一个或多个非换行符字符
```

## 分组提取功能详解

### 使用 `re.FindSubmatchAll()` 提取所有分组数据

`re.FindSubmatchAll()` 函数返回所有匹配项，并且每个匹配项包含了正则表达式中所有分组捕获的内容。

```yak
// 分组提取示例 - 从多个"for"行中提取后面的内容
raw = `this is text for Hello-World
for Foo-Bar
for Me
for You`
result = re.FindSubmatchAll(raw, `for ([^\n]+)`) // 括号创建了一个捕获组
for submatch in result {
    println(`submatch-raw: %v, submatch[0]: %v submatch[1]: %v` % [submatch, submatch[0], submatch[1]])
}
/**
OUTPUT:

submatch-raw: [for Hello-World Hello-World], submatch[0]: for Hello-World submatch[1]: Hello-World
submatch-raw: [for Foo-Bar Foo-Bar], submatch[0]: for Foo-Bar submatch[1]: Foo-Bar
submatch-raw: [for Me Me], submatch[0]: for Me submatch[1]: Me
submatch-raw: [for You You], submatch[0]: for You submatch[1]: You
*/
// 解析：
// submatch[0] 是完整匹配项
// submatch[1] 是第一个捕获组(括号内)的内容
```


### HTML 标签内容提取技巧

#### 使用 `re.FindSubmatch()` 提取 HTML 标签内容

```yak
// HTML标题提取示例
rawData = `<html>
<head>
    <title>Title For Page</title>
</head>
<body>
</body>
</html>`
submatchResult = re.FindSubmatch(rawData, `<title>(.+?)<\/`)
dump(submatchResult)
/**
OUTPUT:

([]string) (len=2 cap=2) {
 (string) (len=23) "<title>Title For Page</",
 (string) (len=14) "Title For Page"
}
*/
title = submatchResult[1]  // 获取第一个捕获组的内容
dump(title) // (string) (len=14) "Title For Page"
// 解析：
// (.+?) 使用非贪婪匹配模式提取<title>和</之间的内容
// ?表示非贪婪模式，只匹配到第一个</
```

#### 使用 `re.FindGroup()` 简化分组提取

`re.FindGroup()` 提供了更简洁的方式来提取正则表达式中的分组内容，返回一个以分组索引为键的映射。

```yak
// 使用FindGroup简化分组提取
rawData = `<html>
<head>
    <title>Title For Page</title>
</head>
<body>
</body>
</html>`
groups = re.FindGroup(rawData, `<title>(.+?)<\/`)
title = groups["1"]  // 使用字符串索引"1"访问第一个捕获组
dump(title)  // (string) (len=14) "Title For Page"
// 解析：FindGroup返回一个映射，键为分组索引（字符串形式），值为对应的捕获内容
```

### 命名分组捕获 - 增强代码可读性

命名分组是正则表达式的高级特性，允许通过自定义名称而不是索引访问捕获组，使代码更具可读性和可维护性。

```yak
// 命名分组捕获示例
rawData = `<html>
<head>
    <title>Title For Page</title>
</head>
<body>
</body>
</html>`
// 使用 (?P<name>pattern) 语法创建命名分组
groups = re.FindGroup(rawData, `<title>(?P<titleContent>.+?)<\/`)
title = groups["titleContent"]  // 通过命名直接访问分组内容
dump(title)  // (string) (len=14) "Title For Page"
// 解析：
// (?P<titleContent>.+?) 创建了一个名为"titleContent"的捕获组
// 使用命名分组可以提高代码可读性，尤其是在有多个捕获组的情况下
```

## 多行文本处理技巧

### 使用 `(?s)` 标志实现跨行匹配

当需要处理包含换行符的文本内容时，必须使用 `(?s)` 标志来修改 `.` 的行为，使其能匹配包括换行符在内的所有字符。

```yak
// 多行内容提取示例
rawData = `<html>
<head>
    <title>
        Multi
        Line
        Title
    </title>
</head>
</html>`

// 不使用(?s)标志 - 无法匹配多行内容
result = re.FindSubmatch(rawData, `<title>(.+?)</title>`)
dump(result)  // 可能为空，因为.+?无法跨行匹配
// OUTPUT: ([]string) <nil>

// 使用(?s)标志 - 成功匹配多行内容
result = re.FindSubmatch(rawData, `(?s)<title>(.+?)</title>`)
dump(result[1])  // 成功提取多行标题内容
// OUTPUT: (string) (len=46) "\n        Multi\n        Line\n        Title\n    "

// 解析：
// (?s) 启用"单行模式"，允许.匹配包括换行符在内的任何字符
// .+? 非贪婪匹配所有字符，包括换行符
```


## 正则多行匹配：需要增加 `(?i)` 标志

在 yaklang 的 re 模块中，`.` 无法匹配 `\n`，但是如果在正则前面增加 `(?i)` 即可匹配多行内容

```yak

# 案例1：使用 .+ （不带 (?s) 标志）
# .+ 表示：一个或多个任意字符，但默认不匹配换行符
matchResult = re.Match(`<title>.+`, raw) 
dump(matchResult)  # 结果：false
# 原因：
# <title>█           # 只尝试匹配第一行
# 换行后无法继续匹配

# 案例2：使用 .* （不带 (?s) 标志）
# .* 表示：零个或多个任意字符，但默认不匹配换行符
matchResult = re.Match(`<title>.*`, raw) 
dump(matchResult)  # 结果：true
# 原因：
# <title>█          # 匹配第一行直到行尾
#  成功匹配，因为 * 允许匹配零个字符

# 案例3：使用 (?s) 和 .+ 
# (?s) 开启单行模式（DOTALL），允许 . 匹配包括换行符在内的所有字符
matchResult = re.Match(`(?s)<title>.+`, raw) 
dump(matchResult)  # 结果：true
# 原因：
# <title>█         # 开始匹配
#     █████████    # 继续匹配
#     █████████    # 继续匹配
#     ████        # 继续匹配
# </title>█       # 完整匹配成功

```

## 正则多行提取：使用 `(?i)` 标志

```yak
raw = `<title>
    这是一个
    跨越多行的
    标题
</title>`

# 不使用 (?s) - 无法提取完整内容
result = re.FindSubmatch(raw, `<title>(.+)</title>`)
dump(result)  
//OUTPUT: ([]string) <nil>

# 使用 (?s) - 成功提取全部内容
result = re.FindSubmatch(raw, `(?s)<title>(.+)<\/title>`)
dump(result)
title = result[1] // dump(title) (string) (len=49) "\n    这是一个\n    跨越多行的\n    标题\n"
/**
OUTPUT:

([]string) (len=2 cap=2) {
 (string) (len=64) "<title>\n    这是一个\n    跨越多行的\n    标题\n</title>",
 (string) (len=49) "\n    这是一个\n    跨越多行的\n    标题\n"
}
*/
```


## 贪婪匹配与非贪婪匹配

在处理多行内容时，通常需要注意贪婪与非贪婪匹配：

```yak
raw = `<div>第一部分内容</div><div>第二部分内容</div>`

# 贪婪匹配：会匹配到最后一个</div>前的所有内容
result = re.FindSubmatch(raw, `(?s)<div>(.+)</div>`)
dump(result)  # 结果：第一部分内容</div><div>第二部分内容
/**
OUTPUT:

([]string) (len=2 cap=2) {
 (string) (len=58) "<div>第一部分内容</div><div>第二部分内容</div>",
 (string) (len=47) "第一部分内容</div><div>第二部分内容"
}
*/

# 非贪婪匹配：使用 .+? 只匹配到第一个</div>前的内容
result = re.FindSubmatch(raw, `(?s)<div>(.+?)</div>`)
dump(result)  # 结果：第一部分内容
/**
OUTPUT:

([]string) (len=2 cap=2) {
 (string) (len=29) "<div>第一部分内容</div>",
 (string) (len=18) "第一部分内容"
}
*/
```

### 最佳实践

1. 处理HTML等多行结构化文本时，总是考虑使用 `(?s)` 标志
2. 配合非贪婪匹配 `+?` 可以更精确地提取所需内容
3. 在复杂场景中，可以结合使用 `(?s)` 和其他标志，如 `(?i)` (忽略大小写)
4. 提取大型文本块时，使用更精确的边界限制，避免性能问题

通过 `(?s)` 标志，我们可以轻松处理跨越多行的数据提取需求，使正则表达式在处理多行文本时更加强大和灵活。

### 正则表达式修饰符汇总

Yaklang 中的正则表达式支持各种修饰符，用于改变匹配行为：

- `(?i)` - 忽略大小写
- `(?s)` - 单行模式，让 `.` 匹配包括换行符在内的所有字符
- `(?m)` - 多行模式，让 `^` 和 `$` 匹配每行的开始和结束
- `(?U)` - 非贪婪模式，所有量词默认为非贪婪

```yak
// 修饰符组合使用示例
raw = `<HTML>
<head>
    <TITLE>
        Mixed Case
        Multi Line
        Content
    </TITLE>
</head>
</HTML>`

// 使用(?i)和(?s)组合 - 忽略大小写并启用多行匹配
result = re.FindSubmatch(raw, `(?i)(?s)<title>(.+?)</title>`)
dump(result[1])  // 成功匹配不同大小写的多行标题
// OUTPUT: (string) (len=59) "\n        Mixed Case\n        Multi Line\n        Content\n    "

// 简写形式
result = re.FindSubmatch(raw, `(?is)<title>(.+?)</title>`)
dump(result[1])  // 效果相同
// OUTPUT: (string) (len=59) "\n        Mixed Case\n        Multi Line\n        Content\n    "
```

## 高级正则应用场景

### 提取复杂结构化数据

```yak
// 提取HTML表格中的数据
htmlTable = `<table>
    <tr><th>Name</th><th>Age</th></tr>
    <tr><td>Alice</td><td>25</td></tr>
    <tr><td>Bob</td><td>30</td></tr>
</table>`

// 提取所有姓名和年龄
nameAgeResults = re.FindSubmatchAll(htmlTable, `(?s)<tr><td>([^<]+)</td><td>(\d+)</td></tr>`)

for entry in nameAgeResults {
    println("Name: " + entry[1] + ", Age: " + entry[2])
}
// 输出:
// Name: Alice, Age: 25
// Name: Bob, Age: 30
```

### JSON数据提取示例

```yak
// 从JSON字符串中提取特定字段
jsonData = `{
    "users": [
        {"id": 1, "name": "Alice", "email": "alice@example.com"},
        {"id": 2, "name": "Bob", "email": "bob@example.com"}
    ]
}`

// 提取所有电子邮件地址
emails = re.FindSubmatchAll(jsonData, `"email":\s*"([^"]+)"`)
for match in emails {
    println("Email: " + match[1])
}
// 输出:
// Email: alice@example.com
// Email: bob@example.com
```
