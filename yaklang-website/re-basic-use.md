
# [re] 正则工具库

    fn re.QuoteMeta(var_1: string): string

yak 的正则工具包非常简单易用，核心只有两个函数

1. `fn re.Match(var_1: string, var_2: string|[]byte): bool`: 使用正则检查目的字符串是否符合正则，返回 `true/false`
1. `fn re.Grok(var_1: string, var_2: string): yaklib.GrokResult`: 符合 Grok 标准的正则捕获模块

同时继承了 Golang `regexp` 标准库中的几个标准接口

1. [`fn re.Compile(var_1: string): (*regexp.Regexp, error)`](https://golang.org/pkg/regexp/#Compile)
1. [`fn re.CompilePOSIX(var_1: string): (*regexp.Regexp, error)`](https://golang.org/pkg/regexp/#CompilePOSIX)
1. [`fn re.MustCompile(var_1: string): *regexp.Regexp`](https://golang.org/pkg/regexp/#MustCompile)
1. [`fn re.MustCompilePOSIX(var_1: string): *regexp.Regexp`](https://golang.org/pkg/regexp/#MustCompilePOSIX)

## 核心函数之一：`re.Match`

这个函数其实是最基础的正则判断函数，给出一个正则 `pattern`，判断字符串是否符合该正则，如果正则编译失败，或无法匹配到结果，则返回 false，正确匹配到结果返回 true。

同时这个函数也是相当高频使用的。

我们看以下案例：

### 使用 `re.Match` 检查字符串是否符合正则

```go
// 我们构建一个 match
pattern := `matchThis(.*?)txt`

// 我们随便写一个字符串
result := re.Match(pattern, `
asdfas sdfa sdfa
dsfasdfk;iopu34
matchMatchMatchmatchThisasdfnkaopjryqeryjklijklojkloptxt
`)
if !result {
    die("failed to match re:")
}
printf("pattern: %v 匹配成功\n", pattern)

/*
OUTPUT:

pattern: matchThis(.*?)txt 匹配成功
*/
```

### 使用 `re.Match` 检查字节流(`[]byte`)是否符合正则

```go
pattern := `matchThis(.*?)txt`
result := re.Match(pattern, []byte(`
asdfas sdfa sdfa
dsfasdfk;iopu34
matchMatchMatchmatchThisasdfnkaopjryqeryjklijklojkloptxt
`))
if !result {
    die("failed to match re:")
}
printf("pattern: %v 匹配成功\n", pattern)

/*
OUTPUT:

pattern: matchThis(.*?)txt 匹配成功
*/
```
