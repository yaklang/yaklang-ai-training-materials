# Level 1: 字符串高级操作

## 题目描述

编写一个 Yak 脚本，实现字符串的各种高级操作，包括分割、替换、大小写转换等。

要求：
1. 字符串分割和连接
2. 大小写转换
3. 前缀/后缀检查
4. 字符串替换
5. 去除空白字符

## 输入

测试字符串：
```
original = "  Hello, Yaklang World! Welcome to Security Testing.  "
```

## 预期输出

```
=== String Operations ===

Original: "  Hello, Yaklang World! Welcome to Security Testing.  "

1. Trim Operations
   TrimSpace: "Hello, Yaklang World! Welcome to Security Testing."
   TrimPrefix: "  Yaklang World! Welcome to Security Testing.  "
   TrimSuffix: "  Hello, Yaklang World! Welcome to Security"

2. Case Operations
   ToUpper: "  HELLO, YAKLANG WORLD! WELCOME TO SECURITY TESTING.  "
   ToLower: "  hello, yaklang world! welcome to security testing.  "
   Title: "  Hello, Yaklang World! Welcome To Security Testing.  "

3. Split & Join
   Split by space: 10 parts
   Join with '-': "Hello-Yaklang-World-Welcome-to-Security-Testing"

4. Replace Operations
   Replace 'Yaklang' -> 'YAK': "Hello, YAK World! Welcome to Security Testing."
   ReplaceAll 'e' -> 'E': "HEllo, Yaklang World! WElcomE to SEcurity TEsting."

5. Check Operations
   HasPrefix 'Hello': true
   HasSuffix 'Testing.': true
   Contains 'Security': true
   Contains 'Python': false
```

## 解题思路

1. **空白处理**
   - `str.TrimSpace()` - 去除首尾空格
   - `str.TrimPrefix()` - 去除前缀
   - `str.TrimSuffix()` - 去除后缀

2. **大小写转换**
   - `str.ToUpper()` - 转大写
   - `str.ToLower()` - 转小写
   - `str.Title()` - 首字母大写

3. **分割连接**
   - `str.Split()` - 分割字符串
   - `str.Join()` - 连接字符串

4. **替换操作**
   - `str.Replace()` - 替换（首个）
   - `str.ReplaceAll()` - 替换（全部）

5. **检查操作**
   - `str.HasPrefix()` - 检查前缀
   - `str.HasSuffix()` - 检查后缀
   - `str.Contains()` - 包含检查

## 关键知识点

- `str.TrimSpace()`, `str.TrimPrefix()`, `str.TrimSuffix()`
- `str.ToUpper()`, `str.ToLower()`, `str.Title()`
- `str.Split()`, `str.Join()`
- `str.Replace()`, `str.ReplaceAll()`
- `str.HasPrefix()`, `str.HasSuffix()`, `str.Contains()`

## 难度等级

⭐ Level 1 - 考察 str 库的基础函数使用

## 评分标准

- 正确使用 Trim 函数 (20%)
- 正确使用大小写转换 (20%)
- 正确使用 Split/Join (20%)
- 正确使用 Replace (20%)
- 正确使用检查函数 (20%)

