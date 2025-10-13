# Level 1: 字符串处理与格式化

## 题目描述

编写一个 Yak 脚本，处理日志文本，提取和格式化关键信息。

要求：
1. 分割多行日志
2. 提取每行的时间戳、级别、消息
3. 统计各级别日志数量
4. 格式化输出清洗后的日志

## 输入

```
2025-01-15 10:23:45 [ERROR] Database connection failed
2025-01-15 10:23:46 [INFO] Retrying connection...
2025-01-15 10:23:47 [INFO] Connection established
2025-01-15 10:24:01 [WARN] Slow query detected: 2.3s
2025-01-15 10:24:15 [ERROR] Failed to process request
2025-01-15 10:24:16 [INFO] Request queued for retry
```

## 预期输出

```
=== Log Analysis ===
Total lines: 6

=== Statistics ===
ERROR: 2
INFO: 3
WARN: 1

=== Formatted Logs ===
[10:23:45] ERROR: Database connection failed
[10:23:46] INFO: Retrying connection...
[10:23:47] INFO: Connection established
[10:24:01] WARN: Slow query detected: 2.3s
[10:24:15] ERROR: Failed to process request
[10:24:16] INFO: Request queued for retry
```

## 解题思路

1. **字符串分割**
   - 使用 `str.Split(text, "\n")` 分割多行
   - 遍历每一行

2. **模式提取**
   - 使用 `str.Split()` 或正则表达式提取字段
   - 或使用 `str.Contains()`, `str.Index()` 定位

3. **统计计数**
   - 使用 map 记录各级别的数量

4. **格式化输出**
   - 使用 `sprintf` 或 f-string 格式化

## 关键知识点

- `str.Split(s, sep)` - 字符串分割
- `str.Trim(s)` - 去除空格
- `str.Contains(s, substr)` - 包含判断
- `str.Index(s, substr)` - 查找位置
- `str.ReplaceAll(s, old, new)` - 替换
- Map/字典操作

## 难度等级

⭐ Level 1 - 考察字符串基础操作

## 评分标准

- 正确分割行 (20%)
- 正确提取字段 (30%)
- 正确统计数量 (25%)
- 格式化输出正确 (25%)

