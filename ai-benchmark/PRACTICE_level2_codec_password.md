# Level 2: 密码哈希与验证

## 题目描述

编写一个 Yak 脚本，实现一个简单的密码存储和验证系统。

要求：
1. 对密码进行 HMAC-SHA256 哈希（加盐）
2. 存储用户名和密码哈希
3. 实现密码验证功能
4. 支持多个用户
5. 统计验证成功率

## 输入

用户信息：
```
users = [
    {"username": "admin", "password": "Admin@123"},
    {"username": "user1", "password": "Pass123!"},
    {"username": "user2", "password": "Secret456"}
]
```

验证测试：
```
login_attempts = [
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
  Password hash: 8f5e21c3a2b1...
✓ User 'user1' registered
  Password hash: 6a3d42e5f8c9...
✓ User 'user2' registered
  Password hash: 4b7a91f2d6e8...

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
```

## 解题思路

1. **哈希函数选择**
   - 使用 `codec.HmacSha256(salt, password)` 进行哈希
   - 需要一个固定的盐值（salt）

2. **用户注册**
   - 计算密码哈希
   - 存储用户名和哈希值的映射

3. **密码验证**
   - 根据用户名查找存储的哈希
   - 计算输入密码的哈希
   - 比较两个哈希值

4. **统计功能**
   - 记录验证成功和失败次数
   - 计算成功率

## 关键知识点

- `codec.HmacSha256(key, data)` - HMAC-SHA256 哈希
- `codec.EncodeToHex(bytes)` - 字节转十六进制
- Map/字典存储
- 字符串比较
- 统计计算

## 难度等级

⭐⭐ Level 2 - 考察密码学哈希和系统设计

## 评分标准

- 正确实现哈希函数 (30%)
- 正确实现用户存储 (20%)
- 正确实现密码验证 (30%)
- 统计功能完整 (15%)
- 错误处理 (5%)

