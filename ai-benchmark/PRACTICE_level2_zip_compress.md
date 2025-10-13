# Level 2: ZIP 文件压缩与解压

## 题目描述

编写一个 Yak 脚本，实现文件压缩、解压和内容验证的完整流程。

要求：
1. 创建多个测试文件（不同类型）
2. 将文件压缩到 ZIP 包
3. 遍历 ZIP 包列出文件
4. 解压 ZIP 包到新目录
5. 验证文件完整性

## 输入

创建以下测试文件：
```
test_files/
├── config.json      (JSON 配置)
├── readme.md        (Markdown 文档)
├── script.yak       (Yak 脚本)
└── data.csv         (CSV 数据)
```

## 预期输出

```
=== ZIP Compression Test ===

[Step 1] Creating test files...
  Created: config.json (45 bytes)
  Created: readme.md (128 bytes)
  Created: script.yak (89 bytes)
  Created: data.csv (67 bytes)
  Total: 4 files, 329 bytes

[Step 2] Compressing to ZIP...
  Compressed to: test_archive.zip
  ZIP size: 245 bytes
  Compression ratio: 74.47%

[Step 3] Listing ZIP contents...
  1. config.json (45 bytes)
  2. readme.md (128 bytes)
  3. script.yak (89 bytes)
  4. data.csv (67 bytes)

[Step 4] Extracting ZIP...
  Extracted to: extracted/
  Files extracted: 4

[Step 5] Verifying integrity...
  ✓ config.json: Content matches
  ✓ readme.md: Content matches
  ✓ script.yak: Content matches
  ✓ data.csv: Content matches

=== Summary ===
All files verified successfully!
Compression saved: 84 bytes (25.53%)
```

## 解题思路

1. **创建测试数据**
   - 使用 `file.Save()` 创建文件
   - 准备不同类型的文件内容

2. **压缩文件**
   - 使用 `zip.CompressRaw(map)` 内存压缩
   - 或使用 `zip.Compress(zipFile, files...)` 文件压缩
   - 保存到 ZIP 文件

3. **遍历 ZIP**
   - 使用 `zip.Recursive()` 遍历 ZIP 内容
   - 收集文件信息

4. **解压文件**
   - 使用 `zip.Decompress()` 解压到目录
   - 或手动提取文件

5. **验证完整性**
   - 比较原始文件和解压后的文件
   - 验证文件大小和内容

## 关键知识点

- `zip.CompressRaw(data_map)` - 内存数据压缩
- `zip.Compress(zipFile, files...)` - 文件压缩
- `zip.Decompress(zipFile, destDir)` - 解压缩
- `zip.Recursive(zipFile, callback)` - 遍历ZIP
- `file.Save()`, `file.ReadFile()` - 文件操作
- 临时文件管理

## 难度等级

⭐⭐ Level 2 - 考察 ZIP 操作和文件系统

## 评分标准

- 正确创建测试文件 (20%)
- 正确压缩文件 (25%)
- 正确遍历 ZIP (20%)
- 正确解压文件 (20%)
- 完整性验证 (15%)

