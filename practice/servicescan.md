# 端口服务扫描系统

```yak
resultChannel, err := servicescan.Scan("www.example.com", "80,22,443")
die(err)

for i in resultChannel {
    println(i.String())
}
/*
OUTPUT:

[INFO] 2025-03-25 10:40:19 [fingerprint_scan:73] start to scan [www.example.com] 's port: 80,22,443
tcp://www.example.com:443        open   http/3/https
tcp://www.example.com:22        closed
tcp://www.example.com:80         open   http
*/
```

## 参数：只扫描web应用
