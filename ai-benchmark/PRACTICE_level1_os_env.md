# Level 1: 操作系统环境变量操作

## 题目描述

使用 `os` 库获取、设置和管理系统环境变量。

要求：
1. 获取常见环境变量（PATH, HOME）
2. 设置新的环境变量
3. 检查环境变量是否存在
4. 删除环境变量

## 预期输出

```
=== OS Environment Variables ===
PATH: /usr/local/bin:/usr/bin...
HOME: /Users/username
Custom variable set: YAKLANG_TEST=hello
Variable exists: true
Variable deleted: false
✓ All tests passed!
```

## 评分标准

- 正确获取环境变量 (30%)
- 正确设置环境变量 (25%)
- 正确检查存在性 (25%)
- 正确删除环境变量 (20%)

