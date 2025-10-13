# Level 2: 密码哈希与验证系统

## 题目描述

编写一个 Yak 脚本，实现安全的密码存储和验证系统，使用 HMAC-SHA256 进行哈希。

要求：
1. 用户注册时计算密码哈希
2. 存储密码哈希（而非明文）
3. 登录时验证密码
4. 统计登录成功率

## 输入

用户数据：
```
users = [
    {"username": "admin", "password": "Admin@123"},
    {"username": "user1", "password": "Pass123!"},
    {"username": "user2", "password": "Secret456"}
]
```

登录测试：
```
loginAttempts = [
    {"username": "admin", "password": "Admin@123"},  // 正确
    {"username": "admin", "password": "wrongpass"},  // 错误
    {"username": "user1", "password": "Pass123!"},   // 正确
    {"username": "user2", "password": "wrong"},      // 错误
]
```

## 预期输出

```
=== Password Hashing System ===

[Registration] Registering 3 users...
✓ User 'admin' registered
  Password hash: f29b7d91d1014930...
✓ User 'user1' registered
  Password hash: fe57610dfffc08eb...
✓ User 'user2' registered
  Password hash: ca3c98f122d719bc...

[Login Tests] Testing 4 login attempts...
[1/4] admin / Admin@123
  ✓ Login successful
[2/4] admin / wrongpass
  ✗ Login failed: Invalid password
[3/4] user1 / Pass123!
  ✓ Login successful
[4/4] user2 / wrong
  ✗ Login failed: Invalid password

=== Statistics ===
Total attempts: 4
Successful: 2
Failed: 2
Success rate: 50.00%

✓ All tests passed!
```

## 解题思路

1. **密码哈希**
   - 使用 `codec.HmacSha256()` 计算哈希
   - 添加盐值（salt）增强安全性
   - 使用 `codec.EncodeToHex()` 转换为十六进制

2. **用户注册**
   - 遍历用户列表
   - 计算每个密码的哈希
   - 存储到用户数据库（map）

3. **密码验证**
   - 计算输入密码的哈希
   - 与存储的哈希比较
   - 返回验证结果

4. **统计分析**
   - 记录成功和失败次数
   - 计算成功率

## 关键知识点

- `codec.HmacSha256(key, data)` - HMAC-SHA256 哈希
- `codec.EncodeToHex(bytes)` - 字节转十六进制
- 密码安全存储原则
- 哈希比较逻辑
- 统计计算

## 难度等级

⭐⭐ Level 2 - 考察哈希算法和安全编程

## 评分标准

- 正确实现密码哈希 (30%)
- 正确存储和查询 (25%)
- 正确验证密码 (25%)
- 统计分析正确 (20%)
