# Level 2: HTTP POST 请求与表单处理

## 题目描述

编写一个 Yak 脚本，发送 HTTP POST 请求，处理不同类型的请求体（form-data 和 JSON）。

要求：
1. 发送 application/x-www-form-urlencoded POST 请求
2. 发送 application/json POST 请求
3. 解析响应内容
4. 比较两种请求方式的响应

## 测试端点

使用 httpbin.org 的测试 API（或本地测试服务）：
- Form POST: `http://httpbin.org/post`
- JSON POST: `http://httpbin.org/post`

## 预期输出

```
=== HTTP POST Test ===

[1] Form-data POST Request
  URL: http://httpbin.org/post
  Content-Type: application/x-www-form-urlencoded
  Data: username=admin&password=test123
  
  Response Status: 200
  Response contains form data: ✓

[2] JSON POST Request
  URL: http://httpbin.org/post
  Content-Type: application/json
  Data: {"username":"admin","password":"test123"}
  
  Response Status: 200
  Response contains JSON data: ✓

=== Comparison ===
Both requests successful
Form response length: 523 bytes
JSON response length: 531 bytes
```

## 解题思路

1. **Form POST 请求**
   - 构造 form-data 格式的数据
   - 设置正确的 Content-Type
   - 使用 `http.Post()` 或 `poc.HTTP()`

2. **JSON POST 请求**
   - 将数据转为 JSON 格式
   - 设置 `Content-Type: application/json`
   - 发送请求

3. **响应处理**
   - 获取状态码
   - 提取响应 body
   - 解析 JSON 响应

4. **结果比较**
   - 比较两种方式的响应

## 关键知识点

- `http.Post(url, contentType, body)` - POST 请求
- `poc.Post(url, opts...)` - POST 请求（另一种方式）
- `json.dumps(data)` - 转为 JSON
- `codec.EncodeUrl()` - URL 编码
- Content-Type 头部设置

## 难度等级

⭐⭐ Level 2 - 考察 HTTP POST 和不同数据格式处理

## 评分标准

- 正确发送 Form POST (30%)
- 正确发送 JSON POST (30%)
- 正确解析响应 (25%)
- 错误处理和输出 (15%)

