# Yaklang AI 编程能力评估题目集 - 完成总结

## 📊 题目概览

本题目集共包含 **12 个题目**，分为 3 个难度级别，覆盖 Yaklang 编程的核心能力。

### 🟢 Level 1 - 基础级别 (4题)

| 题目 | 考察重点 | 难度 |
|------|---------|------|
| http_header_extract | HTTP 数据包解析 | ⭐ |
| json_parse | JSON 数据处理 | ⭐ |
| service_scan | 服务扫描基础 | ⭐ |
| string_ops | 字符串操作 | ⭐ |

### 🟡 Level 2 - 中级级别 (5题)

| 题目 | 考察重点 | 难度 |
|------|---------|------|
| regex_extract | 正则表达式 | ⭐⭐ |
| codec_chain | 多层编解码 | ⭐⭐ |
| concurrent_scan | 并发编程 | ⭐⭐ |
| file_operations | 文件操作 | ⭐⭐ |
| http_post | HTTP POST请求 | ⭐⭐ |

### 🔴 Level 3 - 高级级别 (3题)

| 题目 | 考察重点 | 难度 |
|------|---------|------|
| sqli_detection | SQL注入检测 | ⭐⭐⭐ |
| fuzzing_test | Fuzzing测试 | ⭐⭐⭐ |
| error_retry | 错误处理与重试 | ⭐⭐⭐ |

## 🎯 题目特色

1. **渐进式难度** - 从基础到高级，循序渐进
2. **实战导向** - 所有题目来源于真实安全测试场景
3. **自动验证** - 每个题目都包含完整的测试用例
4. **详细注释** - 中文注释，帮助理解代码逻辑

## 📂 文件结构

```
ai-benchmark/
├── README.md                              # 总索引
├── SUMMARY.md                            # 本文件
├── PRACTICE_level1_http_header_extract   # Level 1: HTTP头部提取
│   ├── .md                               # 题目描述
│   └── .yak                              # 参考解法
├── PRACTICE_level1_json_parse            # Level 1: JSON解析
├── PRACTICE_level1_service_scan          # Level 1: 服务扫描
├── PRACTICE_level1_string_ops            # Level 1: 字符串处理
├── PRACTICE_level2_regex_extract         # Level 2: 正则提取
├── PRACTICE_level2_codec_chain           # Level 2: 编解码链
├── PRACTICE_level2_concurrent_scan       # Level 2: 并发扫描
├── PRACTICE_level2_file_operations       # Level 2: 文件操作
├── PRACTICE_level2_http_post             # Level 2: HTTP POST
├── PRACTICE_level3_sqli_detection        # Level 3: SQL注入检测
├── PRACTICE_level3_fuzzing_test          # Level 3: Fuzzing测试
└── PRACTICE_level3_error_retry           # Level 3: 错误重试
```

## 🧪 快速测试

### 测试单个题目
```bash
yak PRACTICE_level1_http_header_extract.yak
```

### 批量测试（Level 1）
```bash
for f in PRACTICE_level1_*.yak; do
    echo "Testing $f..."
    yak "$f" && echo "✓ Pass" || echo "✗ Fail"
done
```

### 测试所有题目
```bash
for f in PRACTICE_*.yak; do
    echo "=== Testing $f ==="
    yak "$f" || echo "Failed: $f"
    echo ""
done
```

## 📚 知识点覆盖

### 核心库
- ✅ poc - HTTP 数据包处理
- ✅ servicescan - 端口服务扫描
- ✅ codec - 编码解码
- ✅ re - 正则表达式
- ✅ json - JSON 处理
- ✅ str - 字符串操作
- ✅ file - 文件操作
- ✅ http - HTTP 请求
- ✅ sync - 并发控制

### 编程特性
- ✅ 变量和数据类型
- ✅ 控制流（if/for）
- ✅ 函数和闭包
- ✅ 错误处理（try-catch/defer-recover）
- ✅ 并发编程（goroutine/WaitGroup）
- ✅ 字符串格式化（f-string/sprintf）

### 安全技能
- ✅ HTTP 协议理解
- ✅ SQL 注入检测
- ✅ 敏感信息提取
- ✅ Fuzzing 测试
- ✅ 服务指纹识别
- ✅ 错误重试机制

## 🎓 学习建议

### 初学者（0-2周）
从 Level 1 开始，重点掌握：
- Yak 基础语法
- 常用库函数
- HTTP 数据包处理
- JSON/字符串操作

### 进阶者（2-4周）
完成 Level 2，重点学习：
- 正则表达式应用
- 文件和编解码
- 并发编程基础
- HTTP POST 请求

### 高级者（4周+）
挑战 Level 3，深入研究：
- 漏洞检测逻辑
- Fuzzing 技术
- 错误处理策略
- 代码架构设计

## ✅ 验证状态

所有 12 个题目均已：
- ✅ 创建完整的题目描述（.md）
- ✅ 实现参考解法（.yak）
- ✅ 通过运行验证
- ✅ 包含详细注释
- ✅ 提供扩展思路

## 📝 使用建议

1. **按顺序学习** - 建议从 Level 1 开始，逐步提升
2. **理解而非记忆** - 重点理解代码逻辑，而非死记语法
3. **动手实践** - 尝试修改代码，观察不同的结果
4. **扩展练习** - 每个题目都有扩展建议，可以深入学习

## 🔧 技术要求

- Yaklang 环境已安装
- 具备基本编程知识
- 了解 HTTP 协议基础
- 对网络安全有一定兴趣

## 📞 反馈与贡献

如发现问题或有改进建议，欢迎：
1. 在仓库中提 Issue
2. 提交 Pull Request
3. 完善题目描述和解法

---

**最后更新**: 2025-10-13
**题目总数**: 12
**验证状态**: 全部通过 ✅
