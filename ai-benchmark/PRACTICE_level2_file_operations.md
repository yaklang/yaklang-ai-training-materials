# Level 2: 文件读写与处理

## 题目描述

编写一个 Yak 脚本，读取一个包含主机列表的文件，进行处理后写入新文件。

要求：
1. 创建测试文件并写入主机列表
2. 读取文件内容
3. 解析每行的主机信息（IP:PORT 格式）
4. 过滤掉注释行和空行
5. 将处理后的结果写入新文件
6. 统计并输出结果

## 输入（文件内容）

```
# Host list for scanning
192.168.1.1:80
192.168.1.2:443

# Web servers
10.0.0.1:8080
10.0.0.2:8443

# Invalid or commented
# 172.16.0.1:22
```

## 预期输出

```
=== File Processing ===
Created input file: /tmp/hosts_input.txt
Read 10 lines from file

=== Processing ===
Valid hosts found: 4
  - 192.168.1.1:80
  - 192.168.1.2:443
  - 10.0.0.1:8080
  - 10.0.0.2:8443

Skipped lines: 6 (comments/empty)

=== Output ===
Written to: /tmp/hosts_output.txt
Successfully processed!
```

## 解题思路

1. **文件写入**
   - 使用 `file.WriteFile(filename, content)` 创建测试文件
   - 或使用 `file.Save(filename, content)`

2. **文件读取**
   - 使用 `file.ReadFile(filename)` 读取内容
   - 或使用 `file.ReadLines(filename)` 按行读取

3. **内容处理**
   - 遍历每一行
   - 使用 `str.TrimSpace()` 去除空格
   - 使用 `str.HasPrefix()` 判断注释
   - 验证格式（包含 ":"）

4. **结果输出**
   - 将有效行写入新文件
   - 统计处理结果

5. **清理**
   - 可选：删除临时文件

## 关键知识点

- `file.WriteFile(path, data)` - 写入文件
- `file.ReadFile(path)` - 读取文件
- `file.ReadLines(path)` - 按行读取
- `str.TrimSpace(s)` - 去除首尾空格
- `str.HasPrefix(s, prefix)` - 前缀判断
- 文件路径处理

## 难度等级

⭐⭐ Level 2 - 考察文件操作和数据处理

## 评分标准

- 正确创建和写入文件 (25%)
- 正确读取文件内容 (20%)
- 正确处理和过滤数据 (30%)
- 正确写入输出文件 (20%)
- 错误处理完善 (5%)

