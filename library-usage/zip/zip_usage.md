基于你的测试用例，我为你补充扩展以下 Yaklang zip 库的使用案例：

```yak
// ======================
// 案例 1：带目录结构的压缩
// ======================
rawWithDir = zip.CompressRaw({
    "subdir1/file1.txt": "sub1 content",
    "subdir2/file2.txt": "sub2 content",
    "root.txt": "root content"
})~
dirZipPath = file.Join(yakit.GetHomeTempDir(), "dir_struct.zip")
file.Save(dirZipPath, rawWithDir)
defer file.Remove(dirZipPath)

// 遍历验证目录结构
dirCount = 0
fileCount = 0
zip.Recursive(dirZipPath, (isDir, path, info) => {
    if isDir {
        dirCount++
        println("发现目录:", path)
    } else {
        fileCount++
        println("发现文件:", path)
    }
})
assert dirCount >= 2  // 至少两个子目录
assert fileCount == 3 // 三个文件

// ======================
// 案例 2：二进制文件压缩与解压
// ======================
pngHeader = codec.EncodeToHex("89504E470D0A1A0A0000000D49484452")
binData = codec.EncodeToHex("000102030405")
rawBinary = zip.CompressRaw({
    "image.png": pngHeader,
    "data.bin": binData,
})~
binZipPath = file.Join(yakit.GetHomeTempDir(), "binary.zip")
file.Save(binZipPath, rawBinary)
defer file.Remove(binZipPath)

count=0
files = []
zip.Recursive(binZipPath, (isDir, path, info) => {
    count++
    files = append(files, path)
})

assert "image.png" in files
assert "data.bin" in files
assert 2 == count

// 验证解压zip
decompressPath = str.PathJoin(yakit.GetHomeTempDir(),"binary")
println(decompressPath)
zip.Decompress(binZipPath, decompressPath)~

count = 0
files = []
contents = []
for d in file.ReadFileInfoInDirectory(decompressPath)~{
    count ++
    files = append(files, d.Name)
}
assert "image.png" in files
assert "data.bin" in files
assert 2 == count
// ======================
// 案例 3：中文/特殊字符处理
// ======================
rawSpecial = zip.CompressRaw({
    "中文 文件.txt": "中文内容",
    "file with space.txt": "space content",
    "emoji😊.txt": "😊"
})~
specialZipPath = file.Join(yakit.GetHomeTempDir(), "special.zip")
file.Save(specialZipPath, rawSpecial)
defer file.Remove(specialZipPath)

// 验证特殊文件名
specialFiles = []
zip.Recursive(specialZipPath, (isDir, path, info) => {
    if !isDir {
        specialFiles = append(specialFiles, path)
    }
})
assert "中文 文件.txt" in specialFiles
assert "file with space.txt" in specialFiles
assert "emoji😊.txt" in specialFiles

// ======================
// 案例 4：错误处理演示
// ======================
try {
    // 尝试读取不存在的 ZIP
    basePath= str.PathJoin(os.TempDir(),"/path/not/exist.zip")
    defer file.Remove(basePath)
    zip.Recursive(basePath, (isDir,path,info) => {
    })
} catch err {
    println("成功捕获错误:", err)
}

// ======================
// 案例 5：内存 ZIP 操作
// ======================
memZip = zip.CompressRaw({
    "memory.txt": "直接内存操作",
    "data.json": '{"key": "value"}'
})~

// 直接从内存解析
memZip = zip.CompressRaw({
    "memory.txt": "直接内存操作",
    "data.json": '{"key": "value"}'
})~

// 直接从内存解析
memFiles = []
size = []
zip.RecursiveFromRaw(memZip, (isDir, path, info) => {
    if !isDir {
        memFiles = append(memFiles, path)
        size = append(size, info.Size())
        println(sprintf("文件 %s 大小: %d 字节", path, info.Size()))
    }
})

assert "memory.txt" in memFiles
assert "data.json" in memFiles
assert 18 in size
assert 16 in size
```

补充说明：

1. 目录结构处理：zip 库会自动处理路径分隔符，支持多级目录
2. 二进制安全：支持直接处理二进制数据，如图片、hex 数据等
3. 特殊字符：完美支持 UTF-8 编码，包括中文、空格、emoji 等
4. 内存操作：RecursiveFromRaw 可直接处理内存中的 ZIP 数据，无需落盘
5. 错误处理：建议使用 try-catch 包裹可能出错的操作

关键 API 说明：
- `zip.CompressRaw(map[string]string/bytes)`：内存创建 ZIP
- `zip.Recursive(path, callback)`：遍历磁盘上的 ZIP 文件
- `zip.RecursiveFromRaw(data, callback)`：遍历内存中的 ZIP 数据
- `zip.Decompress(zipPath, targetPath)`：解压 ZIP 文件到指定目录

注意事项：
1. ZIP 路径分隔符统一使用正斜杠 `/`
2. 大文件处理建议使用流式接口（如有）
3. 修改时间等元信息需要通过 info 参数获取
4. 加密 ZIP 需要额外处理（需确认库是否支持）

