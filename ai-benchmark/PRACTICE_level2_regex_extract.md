# Medium: 正则表达式敏感信息提取

## 题目描述

编写一个 Yak 脚本，使用正则表达式从日志文本中提取敏感信息。

要求从以下文本中提取：
1. 所有的邮箱地址
2. 所有的 IPv4 地址
3. 所有的手机号码（格式：13812345678 或 138-1234-5678）
4. 所有的 URL 地址（http/https）
5. 统计每种类型的数量

## 输入

一段包含多种敏感信息的日志文本：

```
User admin@example.com logged in from 192.168.1.100
Contact: support@test.org, Phone: 13812345678
Server: 10.0.0.1:8080, API: https://api.example.com/v1/users
Emergency contact: 138-1234-5678
Another server at http://backup.test.com:9090 (IP: 172.16.0.50)
Customer service: service@company.cn, Tel: 13900001234
```

## 预期输出

```
=== Email Addresses (4 found) ===
1. admin@example.com
2. support@test.org
3. service@company.cn

=== IP Addresses (3 found) ===
1. 192.168.1.100
2. 10.0.0.1
3. 172.16.0.50

=== Phone Numbers (3 found) ===
1. 13812345678
2. 138-1234-5678
3. 13900001234

=== URLs (2 found) ===
1. https://api.example.com/v1/users
2. http://backup.test.com:9090

=== Summary ===
Total emails: 4
Total IPs: 3
Total phones: 3
Total URLs: 2
```

## 解题思路

1. **使用 re 库的查找功能**
   - `re.FindAll()` 可以查找所有匹配项
   - `re.ExtractEmail()` 是内置的邮箱提取函数
   - `re.ExtractIP()` 是内置的 IP 提取函数
   - 对于手机号和 URL 需要自定义正则表达式

2. **正则表达式设计**
   - 邮箱：`[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}`
   - IPv4：`\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}`
   - 手机号：`\d{3}-?\d{4}-?\d{4}`
   - URL：`https?://[a-zA-Z0-9.-]+(?::\d+)?(?:/[^\s]*)?`

3. **去重处理**
   - 可能需要对提取的结果去重
   - 使用 map 或 set 来去重

4. **格式化输出**
   - 使用 `sprintf` 或 f-string 格式化输出
   - 按要求的格式展示结果

## 关键知识点

- `re.FindAll(text, pattern)` - 查找所有匹配
- `re.ExtractEmail(text)` - 提取邮箱（内置）
- `re.ExtractIP(text)` - 提取 IP（内置）
- 正则表达式语法
- 字符串格式化
- 数据去重

## 难度等级

⭐⭐ Medium - 考察正则表达式的使用和数据处理能力

## 评分标准

- 正确提取所有邮箱 (20%)
- 正确提取所有 IP 地址 (20%)
- 正确提取所有手机号 (25%)
- 正确提取所有 URL (25%)
- 输出格式正确且统计准确 (10%)

