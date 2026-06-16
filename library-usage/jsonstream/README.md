# jsonstream 库 - 流式 JSON 解析（数据流 + 回调）

`jsonstream` 是 Yaklang 中面向"数据流 + 回调"的 JSON 解析库，底层复用字符级流式解析引擎
`common/jsonextractor`，与 Yaklang AI 解析大模型（LLM）数据流（SSE 流）使用的是同一套引擎。

## 与 json 库的区别

- `json` 库：整体解析，必须拿到完整 JSON 再一次性 `Unmarshal`（`json.loads` / `json.dumps`）。
- `jsonstream` 库：边读边解析，字符级流式 + 回调。支持字段级数据流、容错解析、常量内存处理大字段。

适用场景：处理大文件 / 网络流；解析 LLM 流式响应；只关心部分字段的选择性解析；需要边到达边处理。

## API 速查

入口函数：

- `jsonstream.Extract(input, ...opt)`：解析字符串或字节（`input` 兼容 string/bytes）。
- `jsonstream.ExtractFromReader(reader, ...opt)`：从 `io.Reader` 数据流解析（边写边解析）。

回调选项（均作为入口函数的可变参数传入）：

- `jsonstream.onObject(func(data))`：每个对象解析完成时触发（含嵌套对象与根对象，顺序自底向上）。
- `jsonstream.onArray(func(data))`：每个数组解析完成时触发。
- `jsonstream.onKeyValue(func(key, value))`：每个键值对触发（见下方行为说明）。
- `jsonstream.onRawKeyValue(func(key, value))`：原始键值对回调。
- `jsonstream.onKeyValueEx(func(key, value, parents))`：带父路径（祖先键列表）的键值对回调。
- `jsonstream.onRootMap(func(data))`：仅顶层对象解析完成时触发一次。
- `jsonstream.onConditionalObject(keys, func(data))`：仅当对象同时包含 `keys` 全部键时触发。
- `jsonstream.onField(field, func(key, reader, parents))`：为字段注册字符级流处理器（独立 goroutine）。
- `jsonstream.onFields(fields, func(key, reader, parents))`：多字段匹配（子串包含，大小写不敏感）。
- `jsonstream.onFieldRegexp(pattern, func(key, reader, parents))`：正则匹配字段。
- `jsonstream.onFieldGlob(pattern, func(key, reader, parents))`：Glob 通配符匹配字段。
- `jsonstream.onFinished(func())`：数据流正常解析完成时触发。
- `jsonstream.onError(func(err))`：数据流读取/解析发生错误时触发。

## 关键行为说明（实测，务必注意）

1. `onKeyValue` 的触发范围：不仅对每个标量键值触发，容器（对象/数组）作为某个键的值完成时也会触发一次；
   根对象完成时会以空字符串 `""` 作为 key 触发一次。实战中通常按需 `if key != "" { ... }` 过滤。

2. `onObject` 会对每个对象都触发，包括所有嵌套对象与根对象，顺序为自底向上（先内层后外层）。
   若只想要顶层对象，请用 `onRootMap`。

3. 字段流（`onField` / `onFields` / `onFieldRegexp` / `onFieldGlob`）产出的是"原始值字节"：
   字符串字段会带上首尾双引号且保留转义（`\n`、`\t`、`\uXXXX` 等），数字/布尔等为其原始文本。
   回调中的 `parents` 是该字段的祖先键路径（如 `["company", "team"]`）。
   - 推荐用配套的 JSON 字符串解码器（在 `str` 库）正确还原内容，而不是简单 `str.Trim` 去引号：
     - 一次性：`str.JsonStringDecode(string(raw))` —— 去引号 + 还原转义，容错。
     - 流式：`str.NewJSONStringReader(reader)` —— 包一层字段流，边到达边去引号去转义，且转义跨分片也安全。
     - 按小缓冲读取中文等多字节内容时，可用 `str.NewUTF8Reader(reader)` 避免把字符从中间截断。
   - `str.Trim(string(raw), "\"")` 只去引号、不还原转义，仅适用于确定无转义的简单值。

4. 字段流回调在独立 goroutine 中执行；`Extract` / `ExtractFromReader` 会等待所有字段流 goroutine
   结束后才返回，因此函数返回后可安全读取结果。多个字段并发写共享变量时需自行加锁（`sync.NewMutex()`）。

5. 容错解析：含尾逗号等非标准 JSON 仍能解析出有效部分（数组尾逗号会补一个空串元素）。

## 示例文件

- `jsonstream-practice.yak`：入口与结构级/键值级/条件回调、容错解析。
- `jsonstream-stream.yak`：`io.Pipe` 数据流、字段级字符流、多字段/正则/Glob 匹配、多字段并发。
- `jsonstream-ai.yak`：模拟大模型逐块吐 JSON，边到达边解析并对 content 做字符级实时消费。

## 最小示例

```yak
// 从数据流解析，并实时消费 content 字段
r, w = io.Pipe()
go func() {
    w.WriteString(`{"role": "assistant", "content": "Hello Yak AI"}`)
    w.Close()
}()

jsonstream.ExtractFromReader(r,
    jsonstream.onField("content", func(key, reader, parents) {
        // 用配套的流式 JSON 字符串解码器：边到达边去引号、还原转义、UTF-8 安全
        decoded = str.NewJSONStringReader(reader)
        println("content:", string(io.ReadAll(decoded)~))
    }),
)
```

## 配套：str 库的流式 JSON 与 token 辅助函数

字段流给出的是带引号和转义的原始值，配合 `str` 库的这几个函数处理最稳妥（详见 `library-usage/str/str-basic.md`）：

- `str.JsonStringDecode(raw)`：一次性解码 JSON 字符串值（去引号 + 还原转义，容错）。
- `str.NewJSONStringReader(reader)`：流式解码 JSON 字符串值，转义跨分片也安全（AI 流式输出首选）。
- `str.NewUTF8Reader(reader)`：UTF-8 安全读取，按小缓冲读中文等多字节内容不乱码。
- `str.CalcTokenCount(text)` / `str.EncodeTokens` / `str.DecodeTokens`：基于 Qwen BPE 的 token 计算与编解码，用于 AI 上下文预算估算。
