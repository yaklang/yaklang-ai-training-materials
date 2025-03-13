# HTTP 数据包操作习题(1)

## 提取一个数据包的 User-Agent

```yak
packet = `GET / HTTP/1.1
Host: www.example.com
User-Agent: MyUserAgent/1.1
`

data = poc.GetHTTPPacketHeader(packet, "user-agent")
dump(data)
//OUTPUT: (string) (len=15) "MyUserAgent/1.1"
```

关于 poc.GetHTTPPacketHeader : `func GetHTTPPacketHeader(packet []byte, key string) (header string)`
GetHTTPPacketHeader 是一个辅助函数，用于获取请求报文中指定的请求头，其返回值为string

## 提取一个数据包的 Cookie / Session

```yak
packet = `GET / HTTP/1.1
Host: www.example.com
User-Agent: MyUserAgent/1.1
Cookie: PHPSESSION=kljasdfgjlk; CAPTCHASESSION=111assadf;
`

data = poc.GetHTTPPacketCookie(packet, "PHPSESSION")
dump(data)
//OUTPUT:(string) (len=11) "kljasdfgjlk"
```

## 提取请求数据包全部的 Cookie

```yak
packet = `GET / HTTP/1.1
Host: www.example.com
User-Agent: MyUserAgent/1.1
Cookie: PHPSESSION=kljasdfgjlk; CAPTCHASESSION=111assadf;
`

data = poc.GetHTTPPacketCookies(packet)
dump(data)
/*
(map[string]string) (len=2) {
 (string) (len=10) "PHPSESSION": (string) (len=11) "kljasdfgjlk",
 (string) (len=14) "CAPTCHASESSION": (string) (len=9) "111assadf"
}
*/
```

## 如果一个数据包同名 Cookie 多个值，提取全部值

```
packet = `GET / HTTP/1.1
Host: www.example.com
User-Agent: MyUserAgent/1.1
Cookie: PHPSESSION=kljasdfgjlk; CAPTCHASESSION=111assadf; PHPSESSION=abc;
`

data = poc.GetHTTPPacketCookieValues(packet, "PHPSESSION")
dump(data)
/*
([]string) (len=2 cap=2) {
 (string) (len=11) "kljasdfgjlk",
 (string) (len=3) "abc"
}
*/
```

## 获取 HTTP 请求包的 Body

```yak
packet = `GET / HTTP/1.1
Host: www.example.com
User-Agent: MyUserAgent/1.1
Cookie: PHPSESSION=kljasdfgjlk; CAPTCHASESSION=111assadf; PHPSESSION=abc;
Content-Length: 5

Body
`

body = poc.GetHTTPPacketBody(packet /*type: []byte*/)
dump(body)
/*
([]uint8) (len=5 cap=512) {
 00000000  42 6f 64 79 0a                                    |Body.|
}
*/
```

## 获取 HTTP 响应包的 Body

```yak
packet = `HTTP/1.1 200 OK
Content-Length: 3

abc`

body = poc.GetHTTPPacketBody(packet /*type: []byte*/)
dump(body)
/*
([]uint8) (len=3 cap=512) {
 00000000  61 62 63                                          |abc|
}
*/
```

## 切割 HTTP 请求包的 Body 和 Header

```yak
packet = `GET / HTTP/1.1
Host: www.example.com
User-Agent: MyUserAgent/1.1
Cookie: PHPSESSION=kljasdfgjlk; CAPTCHASESSION=111assadf; PHPSESSION=abc;
Content-Length: 4

Body`

header, body = poc.Split(packet /*type: []byte*/)
println(header)
/*
GET / HTTP/1.1
Host: www.example.com
User-Agent: MyUserAgent/1.1
Cookie: PHPSESSION=kljasdfgjlk; CAPTCHASESSION=111assadf; PHPSESSION=abc;
Content-Length: 4

*/
dump(body)
/*
([]uint8) (len=4 cap=512) {
 00000000  42 6f 64 79                                       |Body|
}
*/
```

## 切割 HTTP 响应包的 Body 和 Header

```
// Start Generation Here
```yak
packet = `HTTP/1.1 200 OK
Content-Type: text/html
Content-Length: 11

hello world`

header, body = poc.Split(packet /*type: []byte*/)
println(header)
/*
HTTP/1.1 200 OK
Content-Type: text/html
Content-Length: 11

*/
dump(body)
/*
([]uint8) (len=11 cap=512) {
 00000000  68 65 6c 6c 6f 20 77 6f 72 6c 64                 |hello world|
}
*/
```

## 提取HTTP响应数据包中的响应码 StatusCode

```yak
packet = `HTTP/1.1 200 OK
Content-Type: text/html
Content-Length: 11

hello world`

code = poc.GetStatusCodeFromResponse(packet /*type: []byte*/)
dump(code)
```

## 提取HTTP请求中的路径(包含请求参数 query)

```yak
httpRequest = `GET /path1/path2/dirName/file.txt?key=value HTTP/1.1
Host: www.example.com

`
result = poc.GetHTTPRequestPath(httpRequest)
dump(result)
//OUTPUT: (string) (len=39) "/path1/path2/dirName/file.txt?key=value"
```

## 提取HTTP请求中的路径(不包含 query):str.Cut切分法

```yak
httpRequest = `GET /path1/path2/dirName/file.txt?key=value HTTP/1.1
Host: www.example.com

`
result = poc.GetHTTPRequestPath(httpRequest)
removeQuery, _, _ = str.Cut(result, "?")
println(`result: %v
removeQuery: %v` % [result, removeQuery])
/**
OUTPUT:

result: /path1/path2/dirName/file.txt?key=value
removeQuery: /path1/path2/dirName/file.txt
 */
```

## 提取 HTTP 请求中的路径，不包含 Query

```yak
httpRequest = `GET /path1/path2/dirName/file.txt?key=value&key2=foo-bar HTTP/1.1
Host: www.example.com

`
result = poc.GetHTTPRequestPathWithoutQuery(httpRequest)
dump(result) 
/**
OUTPUT:

(string) (len=29) "/path1/path2/dirName/file.txt"
 */
```


## 提取 HTTP 请求中的 Query 参数（指的是 ? 后的参数）

提取 HTTP 请求中指定 Query 参数

```yak
httpRequest = `GET /path1/path2/dirName/file.txt?key=value HTTP/1.1
Host: www.example.com

`
result = poc.GetHTTPPacketQueryParam(httpRequest, "key")
dump(result) // (string) (len=5) "value"
```

## 提取 HTTP 请求中所有 Query 参数

```yak
httpRequest = `GET /path1/path2/dirName/file.txt?key=value&key2=foo-bar HTTP/1.1
Host: www.example.com

`
result = poc.GetAllHTTPPacketQueryParams(httpRequest)
dump(result) 
/**
OUTPUT:

(map[string]string) (len=2) {
 (string) (len=3) "key": (string) (len=5) "value",
 (string) (len=4) "key2": (string) (len=7) "foo-bar"
}
 */
```
