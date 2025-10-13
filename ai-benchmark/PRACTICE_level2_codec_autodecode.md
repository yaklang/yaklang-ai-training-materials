# Level 2: 自动解码与数据提取

## 题目描述

编写一个 Yak 脚本，实现对混合编码数据的自动识别和解码，提取隐藏信息。

要求：
1. 自动识别编码类型（Base64、Hex、URL编码等）
2. 递归解码直到获得明文
3. 提取解码后的敏感信息
4. 统计解码步骤和编码类型

## 输入

测试数据包含多种编码组合：
```
encodedData1 = "SGVsbG8lMjBZYWtsYW5n"  // Base64(URL-encoded)
encodedData2 = "48656c6c6f20576f726c64"  // Hex
encodedData3 = "YWRtaW4lM0FwYXNzd29yZDEyMw=="  // Base64(URL-encoded credentials)
```

## 预期输出

```
=== Auto Decode Tool ===

[Test 1] Decoding: SGVsbG8lMjBZYWtsYW5n
  Step 1: Base64 decode -> Hello%20Yaklang
  Step 2: URL decode -> Hello Yaklang
  Final result: "Hello Yaklang"
  Total steps: 2

[Test 2] Decoding: 48656c6c6f20576f726c64
  Step 1: Hex decode -> Hello World
  Final result: "Hello World"
  Total steps: 1

[Test 3] Decoding: YWRtaW4lM0FwYXNzd29yZDEyMw==
  Step 1: Base64 decode -> admin%3Apassword123
  Step 2: URL decode -> admin:password123
  Final result: "admin:password123"
  Total steps: 2
  [ALERT] Detected credentials: username=admin, password=password123

=== Summary ===
Total tests: 3
Average decode steps: 1.67
Detected sensitive data: 1
```

## 解题思路

1. **自动检测编码**
   - 检查是否为 Base64（正则匹配）
   - 检查是否为 Hex（正则匹配）
   - 检查是否为 URL 编码（包含 %）

2. **递归解码**
   - 使用 `codec.AutoDecode()` 自动解码
   - 或手动尝试多种解码方式
   - 记录每一步的解码结果

3. **敏感信息提取**
   - 查找用户名密码模式（user:pass）
   - 提取 Token、API Key 等
   - 使用正则表达式匹配

4. **统计分析**
   - 记录解码步骤数
   - 统计编码类型
   - 标记敏感数据

## 关键知识点

- `codec.AutoDecode()` - 自动解码
- `codec.DecodeBase64()` - Base64 解码
- `codec.DecodeHex()` - Hex 解码
- `codec.DecodeUrl()` - URL 解码
- 编码检测逻辑
- 递归解码模式

## 难度等级

⭐⭐ Level 2 - 考察编解码和数据提取

## 评分标准

- 正确检测编码类型 (25%)
- 正确递归解码 (30%)
- 提取敏感信息 (25%)
- 统计分析 (20%)

