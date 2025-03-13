# Yaklang 中正则练习题

## 使用正则判断是否存在（Match）

```yak
raw = `this is text for Hello-World`
result = re.Match(`this is text for .+`/*pattern: string*/, raw)
dump(result) // (bool) true
```

案例2:

```yak
raw = `this is text for Hello-World`
result = re.Match(`no existed text for .+`/*pattern: string*/, raw)
dump(result) // (bool) false
```

## 使用正则提取文本中数据(无分组)

```
raw = `this is text for Hello-World`
result = re.Find(raw, `for .+`)
dump(result) // (string) (len=15) "for Hello-World"
```

## 使用正则提取所有符合要求的数据（不分组）

```yak
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
```

## 使用正则提取所有关键分组数据（分组）

```yak
raw = `this is text for Hello-World
for Foo-Bar
for Me
for You`
result = re.FindSubmatchAll(raw, `for ([^\n]+)`) // for 后包含分组，这个组的index为1
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
```

## 使用正则提取一个 HTML 中的 TITLE 标签

### 使用 Submatch 进行分组匹配

```yak
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
title = submatchResult[1]
dump(title) // (string) (len=14) "Title For Page"
```

### 无参数分组

```yak
rawData = `<html>
<head>
    <title>Title For Page</title>
</head>
<body>
</body>
</html>`
groups = re.FindGroup(rawData, `<title>(.+?)<\/`)
title = groups["1"]
dump(title)  // (string) (len=14) "Title For Page"
```

### 正则支持按照参数名称分组（自定义参数名）

这段代码用于从HTML文档中提取 `<title>` 标签内的文本内容，核心是通过正则表达式的命名分组实现精准捕获。

```
rawData = `<html>
<head>
    <title>Title For Page</title>
</head>
<body>
</body>
</html>`
groups = re.FindGroup(rawData, `<title>(?P<paramName>.+?)<\/`)
title = groups["paramName"]
dump(title)  // (string) (len=14) "Title For Page"
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