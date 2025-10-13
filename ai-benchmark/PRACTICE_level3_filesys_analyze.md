# Level 3: 文件系统分析工具

## 题目描述

编写一个 Yak 脚本，实现一个文件系统分析工具，统计目录结构、文件类型分布、大小分析等。

要求：
1. 递归遍历目录树
2. 统计文件类型分布
3. 分析文件大小分布
4. 查找最大的文件
5. 计算总大小和文件数
6. 生成分析报告

## 输入

分析目标：当前项目的 `ai-benchmark` 目录

## 预期输出

```
=== Filesystem Analysis Tool ===

Target: /path/to/ai-benchmark
Scanning...

=== Analysis Report ===

1. Overview
   Total files: 24
   Total directories: 1
   Total size: 156.5 KB
   Average file size: 6.5 KB

2. File Type Distribution
   .md files: 12 (50.00%)
   .yak files: 12 (50.00%)

3. Size Distribution
   < 1 KB: 0 files
   1-10 KB: 18 files (75.00%)
   10-50 KB: 5 files (20.83%)
   50-100 KB: 1 file (4.17%)
   > 100 KB: 0 files

4. Top 5 Largest Files
   1. PRACTICE_level3_sqli_detection.yak (15.2 KB)
   2. PRACTICE_level2_file_operations.yak (12.8 KB)
   3. PRACTICE_level3_fuzzing_test.yak (11.5 KB)
   4. PRACTICE_level3_error_retry.yak (10.9 KB)
   5. PRACTICE_level2_concurrent_scan.yak (8.7 KB)

5. Files by Level
   Level 1 files: 8 files (32.5 KB)
   Level 2 files: 10 files (78.2 KB)
   Level 3 files: 6 files (45.8 KB)
```

## 解题思路

1. **目录遍历**
   - 使用 `filesys.Recursive()` 递归遍历
   - 使用 `onFileStat` 和 `onDirStat` 回调

2. **数据收集**
   - 收集文件路径、大小、类型
   - 使用 map 统计文件类型
   - 使用数组收集文件信息

3. **文件类型分类**
   - 使用 `file.GetExt()` 获取扩展名
   - 统计每种类型的数量

4. **大小分析**
   - 定义大小区间
   - 统计各区间的文件数
   - 排序找出最大文件

5. **报告生成**
   - 格式化输出统计信息
   - 计算百分比
   - 展示层次结构

## 关键知识点

- `filesys.Recursive(dir, opts...)` - 递归遍历
- `filesys.onFileStat(callback)` - 文件回调
- `filesys.onDirStat(callback)` - 目录回调
- `file.GetExt(path)` - 获取扩展名
- `info.Size()` - 获取文件大小
- 数组排序和切片
- 百分比计算

## 难度等级

⭐⭐⭐ Level 3 - 综合考察文件系统操作和数据分析

## 评分标准

- 正确遍历目录结构 (20%)
- 正确统计文件类型 (20%)
- 正确分析文件大小 (25%)
- 报告格式清晰 (20%)
- 代码结构良好 (15%)

