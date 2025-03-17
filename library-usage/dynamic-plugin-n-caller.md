# Yaklang 教程：基于代码示例的深入解析

在本教程中，我们将通过一段完整的代码示例，逐步讲解 Yaklang 的核心功能和用法。这段代码展示了如何利用 Yaklang 的内置库（如 `db`、`hook` 和 `poc`）来实现一个动态插件系统，并结合 HTTP 请求处理完成特定任务。

---

## 1. **代码功能概述**

这段代码的核心目标是：
- 动态生成一个临时插件脚本，用于拦截和处理 HTTP 请求。
- 使用 `hook.NewMixPluginCaller` 调用该插件，并模拟多个 HTTP 请求流。
- 验证插件是否正确地处理了请求并更新了数据库中的计数器。

---

## 2. **代码逐行解析**

### **2.1 插件脚本生成**
```yak
key = randstr(20)

code = f`key="${key}";db.SetKey(key, 0)
count=0
mirrorNewWebsitePath = (tls, url, req, rsp, body) => {
    count++
    println(url)
    db.SetKey(key, count)
}`
```

#### **关键点解析**
1. **随机字符串生成**：
   - `randstr(20)` 生成一个长度为 20 的随机字符串，作为唯一的键值存储标识。
   - 这种方法常用于动态生成唯一标识符，避免冲突。

2. **插件脚本内容**：
   - `f\`...\`` 是 Yaklang 的模板字符串语法，允许嵌入变量。
   - `db.SetKey(key, 0)` 初始化数据库中的键值为 0。
   - 定义了一个回调函数 `mirrorNewWebsitePath`，用于处理每个 HTTP 请求流：
     - 每次调用时，计数器 `count` 自增。
     - 打印请求的 URL。
     - 更新数据库中的计数器值。

3. **动态脚本生成**：
   - `code` 是一个字符串形式的脚本，后续会被传递给 `db.CreateTemporaryYakScript` 创建临时插件。

---

### **2.2 插件注册与清理**
```yak
pluginName = db.CreateTemporaryYakScript("mitm", code)~
defer db.DeleteYakScriptByName(pluginName)
```

#### **关键点解析**
1. **创建临时插件**：
   - `db.CreateTemporaryYakScript("mitm", code)` 将脚本内容注册为一个名为 `mitm` 的临时插件。
   - 返回值 `pluginName` 是插件的唯一名称。

2. **资源清理**：
   - `defer db.DeleteYakScriptByName(pluginName)` 确保在程序结束时删除插件，避免污染数据库。

---

### **2.3 插件调用器初始化**
```yak
caller = hook.NewMixPluginCaller()~
caller.LoadPlugin(pluginName, )
```

#### **关键点解析**
1. **插件调用器**：
   - `hook.NewMixPluginCaller()` 创建一个插件调用器实例。
   - `caller.LoadPlugin(pluginName, )` 加载指定插件。

2. **错误处理**：
   - `~` 波浪操作符用于捕获潜在错误，确保程序不会因插件加载失败而崩溃。

---

### **2.4 模拟 HTTP 请求流**
```yak
caller = hook.NewMixPluginCaller()~
caller.LoadPlugin(pluginName, )
for i in [
    {"https": false, "request": "GET /a/b/c HTTP/1.1\r\nHost: www.example.com"}, //1
    {"https": true, "request": "GET /a/b/c HTTP/1.1\r\nHost: www.example.com"},  //2
    {"https": false, "request": "POST /a/b/c HTTP/1.1\r\nHost: www.example.com\r\n"}, //3
    {"https": false, "request": "POST /a/b/ HTTP/1.1\r\nHost: www.example.com"}, //4
    {"https": true,  "request": "GET /a/b/ HTTP/1.: www.example.com"}, //5
    {"https": false, "request": "GET /a/b HTTP/.example.com"}, //6
] {
    i.request = poc.FixHTTPRequest(i.request)
    schema = "http"
    if i.https{
       schema = "https"
    }
    url = poc.GetUrlFromHTTPRequest(schema, i.request)
    caller.MirrorHTTPFlow(i.https, url, i.request, "", "")
}
```

#### **关键点解析**
1. **HTTP 请求修复**：
   - `poc.FixHTTPRequest(i.request)` 修复原始 HTTP 请求数据包，确保其符合标准协议格式。
   - 例如，将 `\n` 替换为标准的 `\r\n`。

2. **提取完整 URL**：
   - `poc.GetUrlFromHTTPRequest(schema, i.request)` 从 HTTP 请求中提取完整的 URL。
   - 根据 `i.https` 判断协议类型（`http` 或 `https`）。

3. **调用插件处理请求**：
   - `caller.MirrorHTTPFlow(...)` 将修复后的请求传递给插件进行处理。

---

### **2.5 断言验证**
```yak
assert parseInt(db.GetKey(key)) == 6
```

#### **关键点解析**
1. **数据库读取**：
   - `db.GetKey(key)` 从数据库中读取计数器值。
   - `parseInt(...)` 将字符串形式的计数器值转换为整数。

2. **断言检查**：
   - 验证计数器值是否等于 6，确保插件正确处理了所有请求。

---

## 3. **扩展知识点**

### **3.1 `poc.FixHTTPRequest` 与 `poc.GetUrlFromHTTPRequest`**
- **`poc.FixHTTPRequest`**：
  - 修复不规范的 HTTP 请求数据包，使其符合标准协议格式。
  - 示例：
    ```yak
    packet := "GET / HTTP/1.1\nHost: www.example.com"
    fixedPacket = poc.FixHTTPRequest(packet)
    dump(fixedPacket)  // 输出标准化后的数据包
    ```

- **`poc.GetUrlFromHTTPRequest`**：
  - 提取完整的 URL，包括协议、主机名和路径。
  - 示例：
    ```yak
    request := "GET /index.html HTTP/1.1\r\nHost: www.example.com"
    url = poc.GetUrlFromHTTPRequest("http", request)
    println(url)  // 输出 "http://www.example.com/index.html"
    ```