#!/bin/bash
# 批量创建题目脚本

# 创建 Level 1 题目
echo "Creating Level 1 topics..."

# str 库相关 (5个)
yak << 'EOF'
题目列表 = [
    ["level1_str_contains", "字符串包含检查", "str.Contains, str.HasPrefix, str.HasSuffix"],
    ["level1_str_index", "字符串索引查找", "str.Index, str.LastIndex, str.Count"],
    ["level1_str_case", "字符串大小写转换", "str.ToUpper, str.ToLower, str.Title"],
    ["level1_str_repeat", "字符串重复和填充", "str.Repeat, strings.Builder"],
    ["level1_math_basic", "基础数学运算", "math operators, float, int"],
]
EOF

echo "Batch create script ready"
