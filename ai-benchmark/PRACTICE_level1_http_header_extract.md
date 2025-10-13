# Easy: HTTP 数据包头部提取

## 题目描述

编写一个 Yak 脚本，从给定的 HTTP 请求数据包中提取以下信息：
1. User-Agent 请求头
2. Host 请求头
3. 所有的 Cookie 值（作为字典返回）
4. 请求方法（GET、POST 等）
5. 请求路径（不包含 Query 参数）

## 输入

一个标准的 HTTP 请求数据包字符串：

```
GET /api/user/info?id=123 HTTP/1.1
Host: www.example.com
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64)
Cookie: session=abc123; token=xyz789
Content-Type: application/json
```

## 预期输出

脚本应该输出：
- User-Agent: `Mozilla/5.0 (Windows NT 10.0; Win64; x64)`
- Host: `www.example.com`
- Cookies: `{"session": "abc123", "token": "xyz789"}`
- Method: `GET`
- Path: `/api/user/info`

## 解题思路

1. **理解 POC 库的 HTTP 处理函数**
   - 使用 `poc.GetHTTPPacketHeader()` 获取指定的 HTTP 头部
   - 使用 `poc.GetHTTPPacketCookies()` 获取所有 Cookie
   - 使用 `poc.GetHTTPRequestPath()` 获取请求路径
   - 使用字符串处理函数提取请求方法

2. **字符串处理**
   - 可能需要使用 `str.Cut()` 或类似函数分割字符串
   - 处理路径时需要移除 Query 参数部分

3. **数据结构**
   - Cookie 以 map/dict 形式返回
   - 其他信息以字符串形式输出

## 关键知识点

- `poc.GetHTTPPacketHeader(packet, headerName)` - 获取指定 HTTP 头部
- `poc.GetHTTPPacketCookies(packet)` - 获取所有 Cookie
- `poc.GetHTTPRequestPathWithoutQuery(packet)` - 获取不含参数的路径
- 字符串分割和处理函数

## 难度等级

⭐ Easy - 主要考察对 Yak 内置 HTTP 处理函数的熟悉程度

## 评分标准

- 正确提取 User-Agent (20%)
- 正确提取 Host (20%)
- 正确提取并解析 Cookie (30%)
- 正确提取请求方法 (15%)
- 正确提取请求路径（不含参数）(15%)

