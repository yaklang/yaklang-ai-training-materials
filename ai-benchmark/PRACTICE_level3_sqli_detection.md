# Hard: HTTP 请求构造与漏洞检测

## 题目描述

编写一个 Yak 脚本，实现一个简单的 SQL 注入检测工具。

要求：
1. 构造包含 SQL 注入 Payload 的 HTTP 请求
2. 发送请求到测试目标
3. 分析响应内容判断是否存在 SQL 注入
4. 支持多个注入点检测（URL 参数、POST 参数）
5. 输出详细的检测报告

## 输入

- 目标 URL：`http://testphp.vulnweb.com/artists.php?artist=1`
- 测试 Payloads：`["' OR '1'='1", "' AND '1'='2", "1' OR '1'='1' --"]`
- 检测方法：基于响应长度差异判断

## 预期输出

```
=== SQL Injection Detection Tool ===
Target: http://testphp.vulnweb.com/artists.php?artist=1

[1/3] Testing payload: ' OR '1'='1
  Request: GET /artists.php?artist=1' OR '1'='1 HTTP/1.1
  Status: 200
  Length: 5432 bytes
  Time: 234ms

[2/3] Testing payload: ' AND '1'='2
  Request: GET /artists.php?artist=1' AND '1'='2 HTTP/1.1
  Status: 200
  Length: 3210 bytes
  Time: 189ms

[3/3] Testing payload: 1' OR '1'='1' --
  Request: GET /artists.php?artist=1' OR '1'='1' -- HTTP/1.1
  Status: 200
  Length: 5438 bytes
  Time: 245ms

=== Detection Results ===
✓ Potential SQL Injection found!

Evidence:
  - Response length variation detected
  - Payload "' OR '1'='1" returned longer response (+69%)
  - Payload "1' OR '1'='1' --" returned similar length
  
Confidence: High
Recommendation: Manual verification required
```

## 解题思路

1. **URL 解析和处理**
   - 使用 `str.Split()` 或 `str.Cut()` 解析 URL
   - 提取 scheme、host、path、query 参数
   - 或使用 URL 解析库

2. **构造测试请求**
   - 使用 `poc.HTTP()` 或 `http.Get()` 发送请求
   - 修改原始参数值，插入 SQL 注入 Payload
   - 使用字符串模板构造完整请求

3. **发送请求并获取响应**
   - 使用 `poc.HTTP(requestRaw)` 发送原始请求
   - 或使用 `http.Get()`, `http.Post()` 等高级函数
   - 处理请求错误

4. **分析响应**
   - 提取响应状态码：`poc.GetStatusCodeFromResponse()`
   - 提取响应 Body：`poc.GetHTTPPacketBody()`
   - 计算响应长度
   - 比较不同 Payload 的响应差异

5. **判断逻辑**
   - 建立基线（原始请求的响应长度）
   - 比较测试 Payload 的响应长度
   - 如果长度差异超过阈值（如 20%），可能存在注入

6. **错误处理**
   - 网络错误处理
   - 超时处理
   - 使用 try-catch 或 `~` 操作符

## 关键知识点

- URL 解析和构造
- `poc.HTTP(rawRequest)` - 发送原始 HTTP 请求
- `http.Get(url, opts...)` - 发送 GET 请求
- `poc.GetHTTPPacketBody()` - 获取响应 Body
- `poc.GetStatusCodeFromResponse()` - 获取状态码
- 字符串处理和模板
- 响应分析和比较
- 漏洞检测逻辑
- 错误处理

## 难度等级

⭐⭐⭐ Hard - 综合考察 HTTP 操作、漏洞检测逻辑、错误处理

## 评分标准

- 正确解析 URL 和参数 (15%)
- 正确构造带 Payload 的请求 (25%)
- 正确发送请求并获取响应 (20%)
- 正确分析响应判断漏洞 (25%)
- 输出格式清晰、错误处理完善 (15%)

## 提示

这是一个综合性题目，考察：
1. HTTP 协议理解
2. 请求构造能力
3. 响应分析能力
4. 漏洞检测思路
5. 代码组织能力

实际测试时注意：
- 可以使用本地测试环境或公开的漏洞测试站点
- 注意请求频率，避免被 WAF 拦截
- 响应长度只是一种简单的判断方法，实际场景可能需要更复杂的分析

