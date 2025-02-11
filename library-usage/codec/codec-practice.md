# Codec 库学习指南

> 这是一个为 AI 设计的 codec 库学习指南，按照功能模块划分，每个部分包含函数说明、示例代码和实际应用场景。

## 快速开始

### 库简介

codec 库是一个用于数据编码、解码和加密的综合工具库，提供了从基础编码到高级加密的完整解决方案。

### 使用方法(以Base64为例)
```go
result = codec.EncodeBase64("example.com")
println(result)
// Output:
//
// ZXhhbXBsZS5jb20=
```

## 模块分类

### 基础编码模块

#### 十六进制编码

**函数列表：**

- `EncodeToHex(data []byte) string`
- `DecodeHex(hexStr string) ([]byte, error)`

**基础示例：**

EncodeToHex 示例

```
data = "example.com"
hexData = codec.EncodeToHex(data)
dump(hexData)
// Output: (string) (len=22) "6578616d706c652e636f6d"
```

**输入输出说明：**

- 输入: 
  - `data`: 字符串类型,需要进行十六进制编码的原始数据
- 输出:
  - `hexData`: 字符串类型,十六进制编码后的结果
  - 每个字节被编码为两个十六进制字符(0-9,a-f)
  - 输出长度是输入长度的2倍

**编码规则:**
1. 每个字节被转换为两个十六进制字符
2. 字符范围为:0-9和a-f(小写)
3. 输出为连续的字符串,没有分隔符

DecodeHex 示例(1)

包含基本错误处理的 DecodeHex 示例

```
hexData = "6578616d706c652e636f6d"
data, err = codec.DecodeHex(hexData)
if err != nil {
    die(err)
}
dump(data)
// Output:
// ([]uint8) (len=11 cap=24) {
//   00000000  65 78 61 6d 70 6c 65 2e  63 6f 6d                 |example.com|
// }
```

上述代码也可以写作：

```
hexData = "6578616d706c652e636f6d"
data, err = codec.DecodeHex(hexData)
die(err)

dump(data)
// Output:
// ([]uint8) (len=11 cap=24) {
//   00000000  65 78 61 6d 70 6c 65 2e  63 6f 6d                 |example.com|
// }
```

上述代码要注意 DecodeHex 的返回值是 `([]byte, error)`，所以需要进行错误处理。

错误处理的方式有多种，如果你确信输入的十六进制字符串是正确的，可以使用 `result = codec.DecodeHex(hexData)~` 来省略 err 的接受

```
hexData = "6578616d706c652e636f6d"
data = codec.DecodeHex(hexData)~
dump(data)

/*
OUTPUT:

([]uint8) (len=11 cap=24) {
 00000000  65 78 61 6d 70 6c 65 2e  63 6f 6d                 |example.com|
}
*/
```


**常见应用场景：**
1. 二进制数据的可视化表示
2. 网络协议数据传输
3. 数据存储格式转换

**AI 学习要点：**
- 输入输出格式
- 错误处理机制
- 性能考虑

---

#### Base 编码
**函数列表：**

- `EncodeBase64(data []byte) string`
- `DecodeBase64(b64Str string) ([]byte, error)`
- `EncodeBase32(data []byte) string`
- `DecodeBase32(b32Str string) ([]byte, error)`
- `EncodeBase64Url(data []byte) string`
- `DecodeBase64Url(b64UrlStr string) ([]byte, error)`

**基础示例：EncodeBase64 与 EncodeBase32**

编码函数 EncodeBase64 与 EncodeBase32 示例：

```
data = "example-data"

b64data = codec.EncodeBase64(data)
println(b64data)
// Output: ZXhhbXBsZS1kYXRh

b32data = codec.EncodeBase32(data)
println(b32data)
// Output: MV4GC3LQNRSS2ZDBORQQ====
```

上述案例，因为函数定义没有返回错误，所以无需错误处理；

**基础示例：EncodeBase64Url**

EncodeBase64Url 是 Base64 URL Safe 编码，它是 Base64 编码的一个变体，专门用于在 URL 中安全传输数据。

```
data = "this is a test data\n!"

b64UrlData = codec.EncodeBase64Url(data)
println(b64UrlData)
// Output: dGhpcyBpcyBhIHRlc3QgZGF0YQoh
```
上述案例，因为函数定义没有返回错误，所以无需错误处理；

**基础示例：DecodeBase64Url / DecodeBase64 / DecodeBase32**

DecodeBase64Url / DecodeBase64 / DecodeBase32 的返回值最后一个都包含一个 error，一般情况下，用户需要进行错误接受和错误处理

DecodeBase64Url 的使用和错误处理方式

```
b64UrlData = "dGhpcyBpcyBhIHRlc3QgZGF0YQoh"
data, err = codec.DecodeBase64Url(b64UrlData)
if err != nil {
    die(err)
}
```

DecodeBase64Url 的错误处理方式2

```
b64UrlData = "dGhpcyBpcyBhIHRlc3QgZGF0YQoh"
data, err = codec.DecodeBase64Url(b64UrlData)
die(err)
```

DecodeBase64Url 的错误处理方式3

```
b64UrlData = "dGhpcyBpcyBhIHRlc3QgZGF0YQoh"
data = codec.DecodeBase64Url(b64UrlData)~
```

DecodeBase64 的错误处理方式

```
b64Data = "ZXhhbXBsZS1kYXRh"
data, err = codec.DecodeBase64(b64Data)
if err != nil {
    die(err)
}
```

DecodeBase64 的错误处理方式2

```
b64Data = "ZXhhbXBsZS1kYXRh"
data, err = codec.DecodeBase64(b64Data)
die(err)
```

DecodeBase64 的错误处理方式3

```
b64Data = "ZXhhbXBsZS1kYXRh"
data = codec.DecodeBase64(b64Data)~
```

DecodeBase32 的错误处理方式

```
b32Data = "MV4GC3LQNRSS2ZDBORQQ===="
data, err = codec.DecodeBase32(b32Data)
if err != nil {
    die(err)
}
```

DecodeBase32 的错误处理方式2

```
b32Data = "MV4GC3LQNRSS2ZDBORQQ===="
data, err = codec.DecodeBase32(b32Data)
die(err)
```

DecodeBase32 的错误处理方式3

```
b32Data = "MV4GC3LQNRSS2ZDBORQQ===="
data = codec.DecodeBase32(b32Data)~
```


**常见应用场景：**
1. 邮件附件编码
2. URL 安全的数据传输
3. 证书和密钥的存储

**AI 学习要点：**
- 各种 Base 编码的区别
- 填充规则
- 使用场景选择

---

### 哈希函数模块

#### SHA / MMH3Hash / MD5

**函数列表：**

- `Sha1(data any) string`
- `Sha224(data any) string`
- `Sha256(data any) string`
- `Sha384(data any) string`
- `Sha512(data any) string`
- `MMH3Hash32(data any) string`
- `MMH3Hash128(data any) string`
- `MMH3Hash128x64(data any) string`
- `Md5(data any) string`

这些函数的声明都类似，注意，他们返回值都是 string，不需要接受错误

这些函数的含义分别为：

**基础示例：**

```
data = codec.Sha1("hello sha1")
println(data) 
// Output: 64faca92dec81be17500f67d521fbd32bb3a6968

data = codec.Sha224("hello world")
println(data)
// Output: 2f05477fc24bb4faefd86517156dafdecec45b8ad3cf2522a563582b

data = codec.Sha256("hello 256")
println(data)
// Output: 6149432197e7dffbe2172c1402094392bfd5258714ff850f299e191b696de0d2

text = "original"
data = codec.MMH3Hash32(text) 
println(data)
// Output: 403177530

data = codec.MMH3Hash128(text) 
println(data)
// Output: 3ff522ddc9c0bf8ab2394cd538906945


data = codec.MMH3Hash128x64(text) 
println(data)
// Output: 3ff522ddc9c0bf8ab2394cd538906945

data = codec.Md5(text)
println(data)
// Output: 919c8b643b7133116b02fc0d9bb7df3f
```

**常见应用场景：**
1. 数据完整性校验
2. 密码存储
3. 数字签名

**AI 学习要点：**
- 不同哈希算法的安全性
- 碰撞概率
- 性能特征

### HTTP 协议中的常见编码

#### URL 编码解码

**函数列表：**

- `EncodeUrl(data any) string`: 把所有字符都进行 URL 编码
- `EscapeUrl(data any) string`: 只对特殊字符进行 URL 编码
- `DecodeUrl(data any) (string, error)`: 对 URL 编码进行解码
- `EscapePathUrl(data any) string`: 只对路径中的特殊字符进行 URL 编码
- `UnescapePathUrl(data any) (string, error)`: 对路径中的 URL 编码进行解码
- `EscapeQueryUrl(data any) string`: 只对查询参数中的特殊字符进行 URL 编码
- `UnescapeQueryUrl(data any) (string, error)`: 对查询参数中的 URL 编码进行解码

**基础示例：**

- URL 编码案例

```
result = codec.EncodeUrl("hello world")
println(result)
// Output: %68%65%6c%6c%6f%20%77%6f%72%6c%64

result = codec.EscapeUrl("hello world\n")
println(result)
// Output: hello+world%0A

result = codec.EscapePathUrl("hello/;world\n")
println(result)
// Output: hello%2F%3Bworld%0A

result = codec.EscapeQueryUrl("hello&world\n")
println(result)
// Output: hello%26world%0A
```

- URL 解码案例

```
result, err = codec.DecodeUrl("hello%2F%3Bworld%0A")
die(err)
println(result)
// Output: hello/;world
```

使用 `~` 可以简化错误处理

```
result = codec.DecodeUrl("hello%2F%3Bworld%0A")~
println(result)
// Output: hello/;world
```

**常见应用场景：**
1. 敏感数据加密
2. 通信加密
3. 存储加密

**AI 学习要点：**
- 密钥管理
- 加密模式选择
- 填充方案

#### DoubleEncodeUrl 双重 URL 编码

**函数列表：**

- `DoubleEncodeUrl(data any) string`: 对 URL 编码进行双重编码
- `DoubleDecodeUrl(data any) (string, error)`: 对双重 URL 编码进行解码

**基础示例：**


编码案例如下：

```
result = codec.DoubleEncodeUrl("hello world")
println(result)
// Output: %2568%2565%256c%256c%256f%2520%2577%256f%2572%256c%2564
```

解码案例如下：

```
result, err = codec.DoubleDecodeUrl("%2568%2565%256c%256c%256f%2520%2577%256f%2572%256c%2564")
die(err)
println(result)
// Output: hello world
```

使用 `~` 可以简化错误处理

```
result = codec.DoubleDecodeUrl("%2568%2565%256c%256c%256f%2520%2577%256f%2572%256c%2564")~
println(result)
// Output: hello world
```


**常见应用场景：**

1. 绕过安全过滤：

```
// 在渗透测试和安全评估中使用
originalPath := "/admin/config"
encodedPath := codec.DoubleEncodeUrl(originalPath)
// 用于测试应用程序是否正确处理编码的URL
```

2. Web 安全测试防火墙

```
// 测试 WAF（Web应用防火墙）规则
payloads := []string{
    "<script>alert(1)</script>",
    "../../etc/passwd",
    "SELECT * FROM users",
}

for _, payload := range payloads {
    encodedPayload := codec.DoubleEncodeUrl(payload)
    // 使用编码后的payload测试应用
    println(encodedPayload)
}
```

#### Html 编码

**函数列表：**

- `EncodeHtml(data any) string`: 对 HTML 编码，使用 `%#` 进行编码
- `EncodeHtmlHex(data any) string`: 对 HTML 编码，使用 `%#x` 进行编码
- `EscapeHtml(data any) string`: 对 HTML 编码，仅编码特殊字符
- `DecodeHtml(data any) string`: 对 HTML 编码进行解码，如果解码失败，会保持原样，因此不需要进行错误处理

**基础示例：**

```
text = "this*is,a<>bad<;data"

result = codec.EncodeHtml(text)
println(result)
// Output: &#116;&#104;&#105;&#115;&#42;&#105;&#115;&#44;&#97;&#60;&#62;&#98;&#97;&#100;&#60;&#59;&#100;&#97;&#116;&#97;

result = codec.EncodeHtmlHex(text)
println(result)
// Output: &#x74;&#x68;&#x69;&#x73;&#x2a;&#x69;&#x73;&#x2c;&#x61;&#x3c;&#x3e;&#x62;&#x61;&#x64;&#x3c;&#x3b;&#x64;&#x61;&#x74;&#x61;

result = codec.EscapeHtml(text)
println(result)
// Output: this*is,a&lt;&gt;bad&lt;;data
```

DecodeHtml 示例

```
result = codec.DecodeHtml("&#116;&#104;&#105;&#115;&#42;&#105;&#115;&#44;&#97;&#60;&#62;&#98;&#97;&#100;&#60;&#59;&#100;&#97;&#116;&#97;")
println(result)
// Output: this*is,a<>bad<;data

result = codec.DecodeHtml("&#x74;&#x68;&#x69;&#x73;&#x2a;&#x69;&#x73;&#x2c;&#x61;&#x3c;&#x3e;&#x62;&#x61;&#x64;&#x3c;&#x3b;&#x64;&#x61;&#x74;&#x61;")
println(result)
// Output: this*is,a<>bad<;data

result = codec.DecodeHtml(`this*is,a&lt;&gt;bad&lt;;data`)
println(result)
// Output: this*is,a<>bad<;data
```

一般来说，上述代码中 DecodeHtml 的返回值是 string ，不需要处理错误。

#### ASCII 编码

**函数列表：**

- `EncodeASCII(data any) string`: 对 ASCII 编码，并在两端加上 "" 专为一个字面量，使用 `\xDD` 进行编码
- `DecodeASCII(data any) (string, error)`: 对 ASCII 编码进行解码，如果解码失败，会返回错误，需要进行错误处理

**基础示例：**

EncodeASCII 示例

```
text = "this is a \nmessage from t\r\nest"
result = codec.EncodeASCII(text)
println(result)
// Output: "this\x20is\x20a\x20\x0amessage\x20from\x20t\x0d\x0aest"
```

DecodeASCII 示例

```
text = `"this\x20is\x20a\x20\x0amessage\x20from\x20t\x0d\x0aest"`
result, err = codec.DecodeASCII(text)
die(err)
println(result)
// Output: this is a 
// message from t
// est
```

使用 `~` 可以简化错误处理

```
text = `"this\x20is\x20a\x20\x0amessage\x20from\x20t\x0d\x0aest"`
result = codec.DecodeASCII(text)~
println(result)
// Output: this is a 
// message from t
// est
```

#### HTTP Chunked 编码

**函数列表：**

- `EncodeChunked(data any) []byte`: 对 HTTP 数据进行 Chunked 编码
- `DecodeChunked(data any) ([]byte, error)`: 对 HTTP 数据进行 Chunked 解码，如果解码失败，会返回错误，需要进行错误处理

HTTP Chunked 编码（分块传输编码）是 HTTP/1.1 中的一种数据传输机制，允许服务器将数据分块发送，每个块都带有自己的大小信息，最后以一个空块（大小为0）结束传输。EncodeChunked 函数将数据转换为分块格式（每个块以其十六进制长度开头，后跟 \r\n，然后是数据本身，再跟 \r\n），而 DecodeChunked 函数则将分块编码的数据解码回原始格式，这种编码方式特别适用于不预先知道内容长度的动态内容传输场景。

**基础示例：**

```
text = "this is a test data"
result = codec.EncodeChunked(text)
dump(result)
/*
OUTPUT:

([]uint8) (len=39 cap=64) {
 00000000  33 0d 0a 74 68 69 0d 0a  35 0d 0a 73 20 69 73 20  |3..thi..5..s is |
 00000010  0d 0a 62 0d 0a 61 20 74  65 73 74 20 64 61 74 61  |..b..a test data|
 00000020  0d 0a 30 0d 0a 0d 0a                              |..0....|
}
*/
```

DecodeChunked 示例

```
text = "4\x0d\x0athis\x0d\x0a9\x0d\x0a\x20is\x20a\x20tes\x0d\x0a6\x0d\x0at\x20data\x0d\x0a0\x0d\x0a\x0d\x0a"
result, err = codec.DecodeChunked(text)
die(err)
println(string(result))
// Output: this is a test data
```

使用 `~` 可以简化错误处理

```
text = "4\x0d\x0athis\x0d\x0a9\x0d\x0a\x20is\x20a\x20tes\x0d\x0a6\x0d\x0at\x20data\x0d\x0a0\x0d\x0a\x0d\x0a"
result = codec.DecodeChunked(text)~
println(string(result))
// Output: this is a test data
```

#### 字符集编码解码

在 Yaklang 中，支持 UTF8 到中文字符集的互相转换和编码解码

**函数列表：**

- `UTF8ToGBK(data []byte) ([]byte, error)`: 将 UTF8 编码的数据转换为 GBK 编码
- `GBKToUTF8(data []byte) ([]byte, error)`: 将 GBK 编码的数据转换为 UTF8 编码
- `UTF8ToGB18030(data []byte) ([]byte, error)`: 将 UTF8 编码的数据转换为 GB18030 编码
- `GB18030ToUTF8(data []byte) ([]byte, error)`: 将 GB18030 编码的数据转换为 UTF8 编码
- `GBKSafe(data []byte) (string, error)`: 判断 GBK 编码输入能否转为 UTF8，如果能转，则返回 UTF8 编码，如果不能转，则返回错误
- `FixUTF8(data []byte) string`: 修复 UTF8 编码的数据(如果数据中包含非法的 UTF8 字符，会使用鬼符代替)

**基础示例：**

UTF8ToGBK 示例

```
text = "你好，中文"
result, err = codec.UTF8ToGBK(text)
die(err)
dump(result)
/*
OUTPUT:

([]uint8) (len=10 cap=512) {
 00000000  c4 e3 ba c3 a3 ac d6 d0  ce c4                    |..........|
}
*/
```

GBKToUTF8 示例

```
text = codec.DecodeHex("c4e3bac3a3acd6d0cec4")~
result, err = codec.GBKToUTF8(text)
die(err)
println(string(result))

/*
OUTPUT:

你好，中文
*/
```

UTF8ToGB18030 示例

```
text = "你好，中文"
result, err = codec.UTF8ToGB18030(text)
die(err)
dump(result)

/*
OUTPUT:

([]uint8) (len=10 cap=512) {
 00000000  c4 e3 ba c3 a3 ac d6 d0  ce c4                    |..........|
}
*/
```

GB18030ToUTF8 示例

```
text = codec.DecodeHex("c4e3bac3a3acd6d0cec4")~
result, err = codec.GB18030ToUTF8(text)
die(err)
println(string(result))

/*
OUTPUT:

你好，中文
*/
```

接下来介绍 GBKSafe 示例

```
text = "你好，中文"
result, err = codec.GBKSafe(text)
die(err)
println(result)
// Output: 你好，中文

text = codec.DecodeHex(`c4e3bac3a3acd6d0cec4`)~
result, err = codec.GBKSafe(text)
die(err)
println(result)
// Output: 你好，中文

```

使用 `~` 可以简化错误处理

```
text = codec.DecodeHex(`c4e3bac3a3acd6d0cec4`)~
result = codec.GBKSafe(text)~
println(result)
// Output: 你好，中文
```

### 加密与解密

#### 填充函数

**函数列表：**

- `PKCS5Padding(data []byte, blockSize int) []byte`: 对数据进行 PKCS5 填充
- `PKCS5UnPadding(data []byte) []byte`: 对 PKCS5 填充的数据进行解填充
- `PKCS7Padding(data []byte) []byte`: 对数据进行 PKCS7 填充
- `PKCS7UnPadding(data []byte) []byte`: 对 PKCS7 填充的数据进行解填充
- `PKCS7PaddingForDES(data []byte) []byte`: 对数据进行 PKCS7 填充，用于 DES 加密
- `PKCS7UnPaddingForDES(data []byte) []byte`: 对 PKCS7 填充的数据进行解填充，用于 DES 解密
- `ZeroPadding(data []byte, blockSize int) []byte`: 对数据进行 0 填充
- `ZeroUnPadding(data []byte) []byte`: 对 0 填充的数据进行解填充

**基础示例：**

PKCS5Padding 示例

```
text = "hello"
result = codec.PKCS5Padding(text, 16)
dump(result)
/*
OUTPUT:

([]uint8) (len=16 cap=16) {
 00000000  68 65 6c 6c 6f 0b 0b 0b  0b 0b 0b 0b 0b 0b 0b 0b  |hello...........|
}
*/

result = codec.PKCS5Padding(text, 8)
dump(result)
/*
OUTPUT:

([]uint8) (len=8 cap=8) {
 00000000  68 65 6c 6c 6f 03 03 03                           |hello...|
}
*/
```

PKCS5UnPadding 示例

```
text = codec.DecodeHex("68656c6c6f0b0b0b0b0b0b0b0b0b0b0b")~
result = codec.PKCS5UnPadding(text)
println(string(result))
// Output: hello
```

PKCS7Padding 示例: 注意 PKCS7 填充和 PKCS5 填充的区别。

```
text = "hello"
result = codec.PKCS7Padding(text)
dump(result)
/*
OUTPUT:

([]uint8) (len=16 cap=16) {
 00000000  68 65 6c 6c 6f 0b 0b 0b  0b 0b 0b 0b 0b 0b 0b 0b  |hello...........|
}
*/
```

PKCS7UnPadding 示例

```
text = codec.DecodeHex("68656c6c6f0b0b0b0b0b0b0b0b0b0b0b")~
result = codec.PKCS7UnPadding(text)
println(string(result))
// Output: hello
```

PKCS7PaddingForDES 示例，填充长度为 8 字节

```
text = "hello"
result = codec.PKCS7PaddingForDES(text)
dump(result)
/*
OUTPUT:

([]uint8) (len=8 cap=8) {
 00000000  68 65 6c 6c 6f 03 03 03                           |hello...|
}
*/
```

PKCS7UnPaddingForDES 示例

```
text = codec.DecodeHex("68656c6c6f030303")~
result = codec.PKCS7UnPaddingForDES(text)
println(string(result))
// Output: hello
```

ZeroPadding 示例

```
text = "hello"
result = codec.ZeroPadding(text, 16)
dump(result)
/*
OUTPUT:

([]uint8) (len=16 cap=16) {
 00000000  68 65 6c 6c 6f 00 00 00  00 00 00 00 00 00 00 00  |hello...........|
}
*/
```

ZeroUnPadding 示例

```
text = codec.DecodeHex("68656c6c6f0000000000000000000000")~
result = codec.ZeroUnPadding(text)
println(string(result))
// Output: hello
```

#### 加密与解密

在 Yaklang 中加密解密一般分为 `AES` 系列，`DES` 系列 `SM` 系列和 `RSA` 系列

我们依次介绍不同系列的用法：

##### AES 系列

**函数列表：**


- `AESCBCEncrypt(data []byte, key []byte, iv []byte) ([]byte, error)`: 对数据进行 AES CBC 加密，默认为 PKCS7Padding
- `AESCBCDecrypt(data []byte, key []byte, iv []byte) ([]byte, error)`: 对数据进行 AES CBC 解密，默认为 PKCS7UnPadding
- `AESCBCEncryptWithZeroPadding(data []byte, key []byte, iv []byte) ([]byte, error)`: 对数据进行 AES CBC 加密，使用 \x00 填充
- `AESCBCDecryptWithZeroPadding(data []byte, key []byte, iv []byte) ([]byte, error)`: 对数据进行 AES CBC 解密，使用 \x00 填充
- `AESECBEncrypt(data []byte, key []byte, iv []byte) ([]byte, error)`: 对数据进行 AES ECB 加密：ECB 模式不需要 IV，传入 nil 或 空字节数组即可
- `AESECBDecrypt(data []byte, key []byte, iv []byte) ([]byte, error)`: 对数据进行 AES ECB 解密：ECB 模式不需要 IV，传入 nil 或 空字节数组即可
- `AESECBEncryptWithZeroPadding(data []byte, key []byte, iv []byte) ([]byte, error)`: 对数据进行 AES ECB 加密，使用 \x00 填充
- `AESECBDecryptWithZeroPadding(data []byte, key []byte, iv []byte) ([]byte, error)`: 对数据进行 AES ECB 解密，使用 \x00 填充
- `AESGCMEncrypt(data []byte, key []byte, iv []byte) ([]byte, error)`: 对数据进行 AES GCM 加密
- `AESGCMDecrypt(data []byte, key []byte, iv []byte) ([]byte, error)`: 对数据进行 AES GCM 解密
- `AESGCMEncryptWithZeroPadding(data []byte, key []byte, iv []byte) ([]byte, error)`: 对数据进行 AES GCM 加密，使用 \x00 填充
- `AESGCMDecryptWithZeroPadding(data []byte, key []byte, iv []byte) ([]byte, error)`: 对数据进行 AES GCM 解密，使用 \x00 填充

key 长度必须为 16（AES-128）、24（AES-192）或 32（AES-256）字节
ECB 模式虽然不需要 IV，但为了接口统一性保留了该参数，使用时传 nil 即可
CBC 和 GCM 模式必须提供 IV，且同一密钥不应重复使用相同的 IV

**基础示例：**

使用 AESCBCEncrypt 和 AESCBCDecrypt 示例

```
text = "this is a secret"
// Key must be 16-byte
key = "secret-key-12345"
result, err = codec.AESCBCEncrypt(key, text, "iv")
die(err)
println(codec.EncodeBase64(result))
// Output: ixo3q8ad44drWlHD3h90gJErbhnbOlaK5MU82FtGXTQ=

result, err = codec.AESCBCEncryptWithZeroPadding(key, text, "iv")
die(err)
println(codec.EncodeBase64(result))
// Output: ixo3q8ad44drWlHD3h90gA==

```

这个示例中，我们使用了 CBC 模式，并提供了 IV。在上述案例中，密码 key 长度为 16 字节。密码只能是 16/24/32 字节，上述内容 text 和 iv 长度并不是 16 的整倍数，所以自动进行了 Padding 处理，一般用户并不需要进行这个处理。在第二个案例中，我们使用了 ZeroPadding 填充。

合理使用 `~` 可以简化错误处理

```
text = "this is a secret"
key = "secret-key-12345"
result = codec.AESCBCEncrypt(key, text, "iv")~
println(codec.EncodeBase64(result))
// Output: ixo3q8ad44drWlHD3h90gJErbhnbOlaK5MU82FtGXTQ=
```

如果需要解密上述内容，可以参考如下代码：

```
encrypted = codec.DecodeBase64(`ixo3q8ad44drWlHD3h90gJErbhnbOlaK5MU82FtGXTQ=`)~
result, err = codec.AESCBCDecrypt(key, encrypted, "iv")
die(err)
println(string(result))
// Output: this is a secret
```

使用 `~` 可以简化错误处理

```
encrypted = codec.DecodeBase64(`ixo3q8ad44drWlHD3h90gJErbhnbOlaK5MU82FtGXTQ=`)~
result = codec.AESCBCDecrypt(key, encrypted, "iv")~
println(string(result))
// Output: this is a secret
```

同理来说，AES ECB 模式下，加密解密代码如下

```
text = "this is a secret"
// Key must be 16-byte
key = "secret-key-12345"
result, err = codec.AESECBEncrypt(key, text, nil)
die(err)
println(codec.EncodeBase64(result))
// Output: pDmoiNftrf8JbFziCD+PNGCSKB1IvY6YJ4GfhsogKck=

clearText = codec.AESECBDecrypt(key, result, nil)~
println(string(clearText))
// Output: this is a secret
```

AES GCM 模式下，加密解密代码如下

```
text = "this is a secret"
// Key must be 16-byte
key = "secret-key-12345"
iv = randstr(16)
result, err = codec.AESGCMEncrypt(key, text, iv)
die(err)
println(codec.EncodeBase64(result))
// Output: pDmoiNftrf8JbFziCD+PNGCSKB1IvY6YJ4GfhsogKck=

clearText = codec.AESGCMDecrypt(key, result, iv)~
println(string(clearText))
// Output: this is a secret
```

**注意事项**

- 在 CBC 和 GCM 模式下，IV 必须唯一，否则会导致解密失败
- 在 ECB 模式下，IV 可以为空，但为了接口统一性保留了该参数，使用时传 nil 即可
- 在使用过程中，如果用户输入是 Base64 的内容，用户需要先 `codec.DecodeBase64(data)~` 进行解码或者 `codec.DecodeHex(data)~` 进行解码。

##### DES 及其变种加密与解密

Yaklang 中 DES 默认的加密解密使用的是 CBC 模式 + ZeroPadding，这个很关键，用户需要特别注意。

**函数列表：**

- `DESCBCEncrypt(data []byte, key []byte, iv []byte) ([]byte, error)`: 对数据进行 DES 加密，默认使用 CBC 模式 + ZeroPadding
- `DESCBCDecrypt(data []byte, key []byte, iv []byte) ([]byte, error)`: 对数据进行 DES 解密，默认使用 CBC 模式 + ZeroPadding
- `DESECBEncrypt(data []byte, key []byte) ([]byte, error)`: 对数据进行 DES ECB 加密，默认使用 ZeroPadding
- `DESECBDecrypt(data []byte, key []byte) ([]byte, error)`: 对数据进行 DES ECB 解密，默认使用 ZeroPadding
- `TripleDESEncrypt(data []byte, key []byte, iv []byte) ([]byte, error)`: 对数据进行 TripleDES 加密，默认使用 CBC 模式 + ZeroPadding
- `TripleDESDecrypt(data []byte, key []byte, iv []byte) ([]byte, error)`: 对数据进行 TripleDES 解密，默认使用 CBC 模式 + ZeroPadding
- `TripleDESECBEncrypt(data []byte, key []byte) ([]byte, error)`: 对数据进行 TripleDES ECB 加密，默认使用 ZeroPadding
- `TripleDESECBDecrypt(data []byte, key []byte) ([]byte, error)`: 对数据进行 TripleDES ECB 解密，默认使用 ZeroPadding

上述为 DES 系列的函数，加密解密函数要注意的是 CBC 模式下，IV 必须唯一，否则会导致解密失败。ECB 无 IV 输入。密钥为 8byte （64bit）
TripleDES 的密钥为 24byte （192bit）

**代码示例：**

DES CBC 模式，加密代码

```
text = "this is a message should be encrypted with CBC DES"
key = "secretme"
iv = "12345678"
result = codec.DESCBCEncrypt(key, text, iv)~
println(codec.EncodeBase64(result))
// Output: g9Oj6shqS4NeyS7skouwwIFS9CfWkm3ccJFpJSZ7zqAPOqCl0l/Fh8qVT96RajvHp0A5TXYXTV0=
```

DES CBC 模式，解密代码

```
key = "secretme"
iv = "12345678"
encrypted = codec.DecodeBase64(`g9Oj6shqS4NeyS7skouwwIFS9CfWkm3ccJFpJSZ7zqAPOqCl0l/Fh8qVT96RajvHp0A5TXYXTV0=`)~

result, err = codec.DESCBCDecrypt(key, encrypted, iv)
die(err)
println(string(result))
// Output: this is a message should be encrypted with CBC DES
```

使用 `~` 可以简化错误处理

```
key = "secretme"
iv = "12345678"
encrypted = codec.DecodeBase64(`g9Oj6shqS4NeyS7skouwwIFS9CfWkm3ccJFpJSZ7zqAPOqCl0l/Fh8qVT96RajvHp0A5TXYXTV0=`)~
result = codec.DESCBCDecrypt(key, encrypted, iv)~
println(string(result))
// Output: this is a message should be encrypted with CBC DES
```

DES ECB 模式，这个模式不需要处理 iv

```
text = "this is a message should be encrypted with DES"
key = "secretme"
result, err = codec.DESECBEncrypt(key, text)
die(err)
println(codec.EncodeBase64(result))
// Output: kDggSPSqv8oqxtIVe8R8JNpoFvCHN64HB8pN4T1+LlqOM08kTSqaNt+ypJVfyrEM
```

上面这段代码对应的解密函数为：

```
key = "secretme"
encrypted := codec.DecodeBase64(`kDggSPSqv8oqxtIVe8R8JNpoFvCHN64HB8pN4T1+LlqOM08kTSqaNt+ypJVfyrEM`)~
result, err = codec.DESECBDecrypt(key, encrypted)
die(err)
println(string(result))
// Output: this is a message should be encrypted with DES
```

TripleDES 系列，加密解密代码如下

```
text = "this is a message should be encrypted with Triple DES"
key = "secretmesecretmesecretme"
iv = "12345678"
result, err = codec.TripleDESCBCEncrypt(key, text, iv)
die(err)
println(codec.EncodeBase64(result))
// Output: g9Oj6shqS4NeyS7skouwwIFS9CfWkm3ccJFpJSZ7zqAPOqCl0l/Fh+Xcu1JxDNvl8a3IiSIJ2Pc=
```

TripleDES CBC 模式，解密代码

```
key = "secretmesecretmesecretme"
iv = "12345678"
encrypted := codec.DecodeBase64(`g9Oj6shqS4NeyS7skouwwIFS9CfWkm3ccJFpJSZ7zqAPOqCl0l/Fh+Xcu1JxDNvl8a3IiSIJ2Pc=`)~
result, err = codec.TripleDESCBCDecrypt(key, encrypted, iv)
die(err)
println(string(result))
// Output: this is a message should be encrypted with Triple DES
```

使用 `~` 可以简化错误处理

```
key = "secretmesecretmesecretme"
iv = "12345678"
encrypted := codec.DecodeBase64(`g9Oj6shqS4NeyS7skouwwIFS9CfWkm3ccJFpJSZ7zqAPOqCl0l/Fh+Xcu1JxDNvl8a3IiSIJ2Pc=`)~
result = codec.TripleDESCBCDecrypt(key, encrypted, iv)~
println(string(result))
// Output: this is a message should be encrypted with Triple DES
```

#### 国密体系 Hash（SM3）

**函数列表：**

- `Sm3(data []byte) []byte`: 对数据进行 SM3 哈希，返回值为字节数组，用户需自行 `codec.EncodeToHex` 进行编码

**代码示例：**

```
text = "Hello World"
result = codec.Sm3(text)
println(codec.EncodeToHex(result))
// Output: 77015816143ee627f4fa410b6dad2bdb9fcbdf1e061a452a686b8711a484c5d7
```

案例2:

```
text = "Hello World"
println(codec.EncodeToHex(codec.Sm3(text)))
// Output: 77015816143ee627f4fa410b6dad2bdb9fcbdf1e061a452a686b8711a484c5d7
```

#### 国密对称加密（SM4）

**函数列表：**

- `Sm4CBCEncrypt(data []byte, key []byte, iv []byte) ([]byte, error)`: 对数据进行 SM4 CBC 加密
- `Sm4CBCDecrypt(data []byte, key []byte, iv []byte) ([]byte, error)`: 对数据进行 SM4 CBC 解密
- `Sm4ECBEncrypt(data []byte, key []byte, iv []byte) ([]byte, error)`: 对数据进行 SM4 ECB 加密
- `Sm4ECBDecrypt(data []byte, key []byte, iv []byte) ([]byte, error)`: 对数据进行 SM4 ECB 解密
- `Sm4GCMEncrypt(data []byte, key []byte, iv []byte) ([]byte, error)`: 对数据进行 SM4 GCM 加密
- `Sm4GCMDecrypt(data []byte, key []byte, iv []byte) ([]byte, error)`: 对数据进行 SM4 GCM 解密
- `Sm4CFBEncrypt(data []byte, key []byte, iv []byte) ([]byte, error)`: 对数据进行 SM4 CFB 加密
- `Sm4CFBDecrypt(data []byte, key []byte, iv []byte) ([]byte, error)`: 对数据进行 SM4 CFB 解密
- `Sm4OFBEncrypt(data []byte, key []byte, iv []byte) ([]byte, error)`: 对数据进行 SM4 OFB 加密
- `Sm4OFBDecrypt(data []byte, key []byte, iv []byte) ([]byte, error)`: 对数据进行 SM4 OFB 解密

**代码示例：**

CBC 模式下，加密解密代码如下

```
text = "this is a text from SM4"
iv = "1234567812345678"

key = "sm4isawesome~!!!"
result, err = codec.Sm4CBCEncrypt(key, text, iv)
die(err)
println(codec.EncodeBase64(result))
// Output: HhYP5XX6rO79j2clTthPyz9lxuvs2WVPllxYZcIKukc=

enc := codec.DecodeBase64(`HhYP5XX6rO79j2clTthPyz9lxuvs2WVPllxYZcIKukc=`)~
result, err = codec.Sm4CBCDecrypt(key, enc, iv)
die(err)
println(string(result))
// Output: this is a text from SM4
```

使用 `~` 可以简化错误处理

```
key = "sm4isawesome~!!!"
iv = "1234567812345678"
enc := codec.DecodeBase64(`HhYP5XX6rO79j2clTthPyz9lxuvs2WVPllxYZcIKukc=`)~
result = codec.Sm4CBCDecrypt(key, enc, iv)~
println(string(result))
// Output: this is a text from SM4
```

使用 Sm4 ECB 的时候，需要注意，虽然 ECB 模式不需要 IV，但为了接口统一性保留了该参数，使用时传 nil 即可

```
text = "this is a text from SM4"
key = "sm4isawesome~!!!"
result, err = codec.Sm4ECBEncrypt(key, text, nil)
die(err)
println(codec.EncodeBase64(result))
// Output: PdkL5fLsbz5ciXXFwAvpxnNiQpu19hHJiyy1CxMg9Uo=

```

上面对应的解密函数为：

```
text = "this is a text from SM4"
enc = codec.DecodeBase64(`PdkL5fLsbz5ciXXFwAvpxnNiQpu19hHJiyy1CxMg9Uo=`)~

result, err = codec.Sm4ECBDecrypt(key, enc, nil)
die(err)
println(string(result))
// Output: this is a text from SM4
```

CBC 和 ECB 一半是最常见的两种，如果用 GCM 的话，和 CBC 几乎是一样的，只需要调整 codec 函数名即可。

```
text = "this is a text from GCM SM4"
iv = "1234567812345678"

key = "sm4isawesome~!!!"
result, err = codec.Sm4GCMEncrypt(key, text, iv)
die(err)
println(codec.EncodeBase64(result))
// Output: 1sOMrcd2m+Ia9Z1XNuTZSUwphPuurKo5RkGcHAHkECg=

text = "this is a text from GCM SM4"
enc := codec.DecodeBase64(`1sOMrcd2m+Ia9Z1XNuTZSUwphPuurKo5RkGcHAHkECg=`)~
result, err = codec.Sm4GCMDecrypt(key, enc, iv)
die(err)
println(string(result))
// Output: this is a text from SM4
```

其他的函数就不再赘述了

**注意事项**

- 在 CBC 和 GCM 模式下，IV 必须唯一，否则会导致解密失败
- 在 ECB 模式下，IV 可以为空，但为了接口统一性保留了该参数，使用时传 nil 即可
- 在使用过程中，如果用户输入是 Base64 的内容，用户需要先 `codec.DecodeBase64(data)~` 进行解码或者 `codec.DecodeHex(data)~` 进行解码。

