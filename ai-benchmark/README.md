# Yaklang AI Programming Benchmark

这是一套用于评估 AI 编程能力的 Yaklang 题目集，涵盖从基础到高级的各种场景。

## 题目分级

### Level 1 - 基础级别 (Basic) ⭐

适合初学者，主要考察对 Yak 基础语法和常用库函数的掌握。

- **PRACTICE_level1_http_header_extract** - HTTP 数据包头部提取
  - 考察点：poc 库基础函数、HTTP 协议理解
  - 难度：⭐
  
- **PRACTICE_level1_service_scan** - 简单服务扫描
  - 考察点：servicescan 库使用、channel 遍历
  - 难度：⭐

- **PRACTICE_level1_json_parse** - JSON 数据解析
  - 考察点：json 库使用、数据结构操作
  - 难度：⭐
  
- **PRACTICE_level1_string_ops** - 字符串处理
  - 考察点：str 库函数、字符串操作
  - 难度：⭐

### Level 2 - 中级级别 (Intermediate) ⭐⭐

需要组合使用多个功能，涉及并发、文件操作、网络编程等。

- **PRACTICE_level2_regex_extract** - 正则表达式数据提取
  - 考察点：re 库使用、正则表达式、数据提取
  - 难度：⭐⭐

- **PRACTICE_level2_codec_chain** - 多层编解码处理
  - 考察点：codec 库、链式编解码、错误处理
  - 难度：⭐⭐

- **PRACTICE_level2_concurrent_scan** - 并发批量扫描
  - 考察点：并发编程、SizedWaitGroup、数据统计
  - 难度：⭐⭐

- **PRACTICE_level2_file_operations** - 文件读写操作
  - 考察点：file 库、文件操作、异常处理
  - 难度：⭐⭐

- **PRACTICE_level2_http_post** - HTTP POST 请求处理
  - 考察点：HTTP POST、表单处理、响应解析
  - 难度：⭐⭐

### Level 3 - 高级级别 (Advanced) ⭐⭐⭐

综合性题目，需要深入理解安全测试场景，组合多种技术。

- **PRACTICE_level3_sqli_detection** - SQL 注入检测
  - 考察点：HTTP 请求构造、漏洞检测逻辑、响应分析
  - 难度：⭐⭐⭐

- **PRACTICE_level3_fuzzing_test** - Fuzzing 模糊测试
  - 考察点：fuzztag 使用、批量测试、结果分析
  - 难度：⭐⭐⭐

- **PRACTICE_level3_error_retry** - 错误处理与重试机制
  - 考察点：错误处理、重试逻辑、超时控制
  - 难度：⭐⭐⭐

## 使用说明

### 运行单个题目

```bash
yak PRACTICE_level1_http_header_extract.yak
```

### 验证所有题目

```bash
# 在 ai-benchmark 目录下
for file in PRACTICE_*.yak; do
    echo "Testing $file..."
    yak "$file" || echo "Failed: $file"
done
```

## 评分标准

每个题目都包含：
1. **题目描述（.md）** - 详细的问题说明、输入输出、解题思路
2. **参考解法（.yak）** - 完整的可执行代码，包含验证测试

评分维度：
- ✅ 功能正确性（60%）- 能否正确完成任务
- ✅ 代码质量（20%）- 代码清晰度、结构合理性
- ✅ 错误处理（10%）- 异常处理是否完善
- ✅ 输出格式（10%）- 输出是否清晰易读

## 题目特点

1. **实战导向** - 所有题目都来源于真实的安全测试场景
2. **渐进式学习** - 从基础到高级，循序渐进
3. **可验证性** - 每个题目都有自动化测试验证
4. **代码注释** - 详细的中文注释，帮助理解

## 学习路径建议

### 入门路径（1-2天）
1. PRACTICE_level1_http_header_extract
2. PRACTICE_level1_string_ops
3. PRACTICE_level1_json_parse
4. PRACTICE_level1_service_scan

### 进阶路径（3-5天）
5. PRACTICE_level2_regex_extract
6. PRACTICE_level2_codec_chain
7. PRACTICE_level2_file_operations
8. PRACTICE_level2_http_post
9. PRACTICE_level2_concurrent_scan

### 高级路径（5-7天）
10. PRACTICE_level3_sqli_detection
11. PRACTICE_level3_fuzzing_test
12. PRACTICE_level3_error_retry

## 扩展练习

完成以上题目后，可以尝试：
- 优化代码性能
- 增加更多测试用例
- 组合多个功能实现更复杂的工具
- 参考 awesome-scripts 目录学习更多高级用法

## 技术支持

- Yaklang 官方文档: https://yaklang.io
- 问题反馈: 请在仓库中提 Issue

---

**注意**：这些题目仅用于学习和评估目的，请勿用于未经授权的安全测试。

