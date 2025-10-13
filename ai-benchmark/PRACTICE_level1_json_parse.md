# Level 1: JSON 数据解析

## 题目描述

编写一个 Yak 脚本，解析 JSON 格式的用户数据，并提取关键信息。

要求：
1. 解析 JSON 字符串
2. 提取用户列表
3. 统计用户总数
4. 找出所有管理员用户
5. 计算用户平均年龄

## 输入

JSON 格式的用户数据：

```json
{
  "company": "Example Corp",
  "users": [
    {
      "id": 1,
      "name": "Alice",
      "age": 28,
      "role": "admin",
      "email": "alice@example.com"
    },
    {
      "id": 2,
      "name": "Bob",
      "age": 35,
      "role": "user",
      "email": "bob@example.com"
    },
    {
      "id": 3,
      "name": "Charlie",
      "age": 42,
      "role": "admin",
      "email": "charlie@example.com"
    },
    {
      "id": 4,
      "name": "David",
      "age": 31,
      "role": "user",
      "email": "david@example.com"
    }
  ]
}
```

## 预期输出

```
=== JSON Data Analysis ===
Company: Example Corp
Total users: 4

=== Admin Users ===
1. Alice (age: 28, email: alice@example.com)
2. Charlie (age: 42, email: charlie@example.com)

=== Statistics ===
Admin count: 2
Regular user count: 2
Average age: 34.00
```

## 解题思路

1. **JSON 解析**
   - 使用 `json.loads()` 或 `json.Unmarshal()` 解析 JSON 字符串
   - 获取解析后的数据结构（map/dict）

2. **数据提取**
   - 访问嵌套的 JSON 数据：`data["users"]`
   - 遍历数组：`for user in users`

3. **数据筛选**
   - 根据条件筛选用户：`if user["role"] == "admin"`
   - 收集符合条件的数据

4. **统计计算**
   - 计数：使用变量累加
   - 求平均值：总和除以数量

## 关键知识点

- `json.loads(jsonString)` - 解析 JSON 字符串
- `json.dumps(data)` - 将数据转为 JSON 字符串
- 字典/Map 访问：`data["key"]`
- 列表遍历：`for item in list`
- 数学计算：求和、平均值

## 难度等级

⭐ Level 1 - 考察 JSON 处理和基础数据操作

## 评分标准

- 正确解析 JSON (25%)
- 正确提取用户列表 (20%)
- 正确筛选管理员用户 (25%)
- 正确计算统计信息 (20%)
- 输出格式清晰 (10%)

