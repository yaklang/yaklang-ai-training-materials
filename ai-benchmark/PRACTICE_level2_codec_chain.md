# Medium: 多层编解码处理

## 题目描述

编写一个 Yak 脚本，处理一个经过多层编码的数据。数据编码顺序为：
1. 原始数据
2. Base64 编码
3. URL 编码
4. Hex 编码

要求：
1. 对给定的原始数据进行多层编码
2. 然后按相反顺序进行解码还原
3. 验证最终结果与原始数据一致

## 输入

原始数据字符串：
```
admin' OR '1'='1' -- 
```

## 预期输出

脚本应该输出每一层编码和解码的结果：
```
=== Encoding Process ===
Original: admin' OR '1'='1' -- 
After Base64: YWRtaW4nIE9SICcxJz0nMScgLS0g
After URL Encode: YWRtaW4lMjclMjBPUiUyMCUyNzElMjclM0QlMjcxJTI3JTIwLS0lMjA%3D
After Hex Encode: 59574674615735684a544a764a5449774d7a4a766369...

=== Decoding Process ===
After Hex Decode: YWRtaW4lMjclMjBPUiUyMCUyNzElMjclM0QlMjcxJTI3JTIwLS0lMjA=
After URL Decode: YWRtaW4nIE9SICcxJz0nMScgLS0g
After Base64 Decode: admin' OR '1'='1' -- 

✓ Verification: Decoded matches original!
```

## 解题思路

1. **编码链**
   - 第一步：使用 `codec.EncodeBase64()` 进行 Base64 编码
   - 第二步：使用 `codec.EncodeUrl()` 进行 URL 编码
   - 第三步：使用 `codec.EncodeToHex()` 进行 Hex 编码

2. **解码链**
   - 第一步：使用 `codec.DecodeHex()` 进行 Hex 解码
   - 第二步：使用 `codec.DecodeUrl()` 进行 URL 解码
   - 第三步：使用 `codec.DecodeBase64()` 进行 Base64 解码

3. **错误处理**
   - 解码函数可能返回错误，需要处理
   - 使用 `~` 操作符或 `die(err)` 处理错误

4. **结果验证**
   - 比较最终解码结果与原始数据
   - 确保完全一致

## 关键知识点

- `codec.EncodeBase64(data)` - Base64 编码
- `codec.DecodeBase64(data)` - Base64 解码
- `codec.EncodeUrl(data)` - URL 编码
- `codec.DecodeUrl(data)` - URL 解码
- `codec.EncodeToHex(data)` - Hex 编码
- `codec.DecodeHex(data)` - Hex 解码
- 字符串和字节数组转换：`string(bytes)`
- 错误处理：`~` 操作符

## 难度等级

⭐⭐ Medium - 考察对编解码函数的理解和链式处理能力

## 评分标准

- 正确实现 Base64 编码/解码 (25%)
- 正确实现 URL 编码/解码 (25%)
- 正确实现 Hex 编码/解码 (25%)
- 正确的链式处理顺序 (15%)
- 错误处理和结果验证 (10%)

