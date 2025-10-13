# Level 3: Fuzzing 模糊测试

## 题目描述

编写一个 Yak 脚本，使用 Fuzzing 技术对 HTTP 请求进行参数变异测试。

要求：
1. 使用 fuzztag 生成测试 Payload
2. 对 HTTP 请求的多个注入点进行 Fuzz
3. 发送变异后的请求
4. 分析响应，识别异常情况
5. 统计测试结果

## 输入

基础 HTTP 请求：
```
GET /search?q={{keyword}}&type={{type}} HTTP/1.1
Host: example.com
User-Agent: {{ua}}
Cookie: session={{session}}
```

Fuzz 字典：
- keyword: SQL注入 Payloads
- type: 1-100的数字
- ua: 常见User-Agent
- session: 随机字符串

## 预期输出

```
=== Fuzzing Test ===
Target template: GET /search?q={{keyword}}&type={{type}}...
Fuzz points: 4

=== Generating Payloads ===
Generated 50 test cases

=== Testing ===
[1/50] Testing: q=' OR '1'='1, type=1, ua=Mozilla/5.0...
  Status: 200, Length: 4532, Time: 123ms
  
[2/50] Testing: q=admin'--,  type=2, ua=Chrome/90.0...
  Status: 500, Length: 1234, Time: 89ms
  ⚠ Anomaly detected: Status 500

[3/50] Testing: q=1' UNION SELECT, type=3, ua=Safari...
  Status: 200, Length: 8901, Time: 234ms
  ⚠ Anomaly detected: Response length increased significantly

... (more tests)

=== Results Summary ===
Total requests: 50
Successful (200): 45
Errors (500): 3
Anomalies detected: 5

Potential vulnerabilities:
  - SQL Injection suspected (3 cases)
  - Unusual response sizes (2 cases)
```

## 解题思路

1. **理解 Fuzztag**
   - `{{int(1-100)}}` - 生成 1-100 的数字
   - `{{list(a|b|c)}}` - 从列表中选择
   - `{{file(dict.txt)}}` - 从文件读取
   - `fuzz.Strings()` - 使用内置字典

2. **构造 Fuzz 请求**
   - 定义请求模板
   - 使用 `fuzz.HTTPRequest()` 或 `fuzz.Strings()`
   - 生成变异请求

3. **发送测试请求**
   - 遍历生成的 Payloads
   - 发送每个变异请求
   - 控制并发和频率

4. **异常检测**
   - 检测 HTTP 状态码异常
   - 检测响应长度异常
   - 检测响应时间异常
   - 检测错误信息

5. **结果统计**
   - 记录各类响应
   - 标记异常情况
   - 生成测试报告

## 关键知识点

- `fuzz.HTTPRequest(template, opts...)` - HTTP Fuzzing
- `fuzz.Strings(template)` - 字符串 Fuzzing
- Fuzztag 语法
- 异常检测逻辑
- 并发控制
- 结果分析

## 难度等级

⭐⭐⭐ Level 3 - 综合考察 Fuzzing、HTTP、异常检测

## 评分标准

- 正确使用 Fuzztag (25%)
- 正确生成和发送 Fuzz 请求 (30%)
- 实现异常检测逻辑 (25%)
- 统计和报告完整 (15%)
- 并发控制合理 (5%)

