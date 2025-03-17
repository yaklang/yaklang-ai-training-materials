```yak
//# HTTP协议操作核心函数库（poc模块）
//## 章节：请求头操作
//### 函数签名：GetHTTPPacketHeader(packet []byte, key string) string
//### 典型场景：User-Agent识别、授权头提取
packet = `GET / HTTP/1.1
Host: www.example.com
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36
`
data = poc.GetHTTPPacketHeader(packet, "User-Agent")  // 精准提取指定头字段


//## 章节：Cookie操作
//### 函数族说明：
//  GetHTTPPacketCookie：单值提取（返回首个匹配）
//  GetHTTPPacketCookies：全Cookie字典（键值对）
//  GetHTTPPacketCookieValues：多值提取（同名Cookie）
//### 安全场景：会话劫持检测、CSRF令牌获取
packet = `GET / HTTP/1.1
Cookie: PHPSESSID=abc123; tracking=enable; PHPSESSID=def456
`
// 单值提取模式
sessionId = poc.GetHTTPPacketCookie(packet, "PHPSESSID")  // 返回首个值："abc123"

// 全量提取模式
allCookies = poc.GetHTTPPacketCookies(packet)  // map包含2个键，PHPSESSID对应"abc123"

// 多值提取模式
multiSessions = poc.GetHTTPPacketCookieValues(packet, "PHPSESSID")  // ["abc123", "def456"]


//## 章节：Body处理
//### 跨协议处理：适用于请求/响应包
//### 二进制安全：返回[]byte类型
reqPacket = `POST /submit HTTP/1.1
Content-Length: 11

hello world`
reqBody = poc.GetHTTPPacketBody(reqPacket)  // 原始字节数据提取

resPacket = `HTTP/1.1 200 OK
Content-Length: 3

abc`
resBody = poc.GetHTTPPacketBody(resPacket)  // 响应体处理方式相同


//## 章节：协议解析
//### 核心函数：Split(packet []byte) (header, body []byte)
//### 应用场景：流量镜像、中间件开发
packet = `GET / HTTP/1.1
Content-Length: 4

Body`
headerPart, bodyPart = poc.Split(packet)  // 协议头与实体分离


//## 章节：响应元数据
//### 关键函数：GetStatusCodeFromResponse
//### 错误处理：无效响应返回0
resPacket = `HTTP/1.1 404 Not Found
Content-Length: 9

Not Found`
statusCode = poc.GetStatusCodeFromResponse(resPacket)  // 快速获取状态码：404


//## 章节：URL解析
//### 功能矩阵：
//  GetHTTPRequestPath：完整路径含Query → "/path?key=val"
//  GetHTTPRequestPathWithoutQuery：纯路径 → "/path"
//  GetHTTPPacketQueryParam：单个参数 → "val"
//  GetAllHTTPPacketQueryParams：参数字典 → map[key]val

// 完整路径提取
req = `GET /api/v1/user?uid=12345 HTTP/1.1`
fullPath = poc.GetHTTPRequestPath(req)  // "/api/v1/user?uid=12345"

// 纯路径提取
cleanPath = poc.GetHTTPRequestPathWithoutQuery(req)  // "/api/v1/user"

// 参数提取
uid = poc.GetHTTPPacketQueryParam(req, "uid")  // "12345"
allParams = poc.GetAllHTTPPacketQueryParams(req)  // map[uid:12345]

```