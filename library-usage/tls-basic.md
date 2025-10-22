### Yaklang TLS协议检测专题教程

#### 1. 基础检测方法
```yak
// 检查目标地址的TLS证书，并返回其证书信息与错误
target = cli.String("target")
cli.check()
for r in tls.Inspect(target)~ {
    dump(r)
}
```

#### 2. 强制HTTP/2检测
```yak
// 强制使用HTTP/2进行检测
check = false
for r in tls.InspectForceHttp2(target)~ {
    if r.Protocol in ["h2"] {
        check = true
    }
}
if !check {
   die("H2 protocol not supported")
}
```

#### 3. 强制HTTP/1.1检测
```yak
// 强制使用HTTP/1.1进行检测
for r in tls.InspectForceHttp1_1(target)~ {
    if r.Protocol == "http/1.1" {
        check = true
    }
}
```

#### 4. 核心功能解析
1. **tls模块方法**：
   - `tls.Inspect()`: 自动协商检测支持的协议
   - `tls.InspectForceHttp2()`: 强制尝试HTTP/2连接
   - `tls.InspectForceHttp1_1()`: 强制使用HTTP/1.1协议

2. **错误处理**：
   - `~`操作符：自动捕获错误
   - `die()`函数：立即终止程序并显示错误信息

3. **参数获取**：
   ```yak
   // 从命令行获取参数（结合cli包）
   target = cli.String("target")
   port = cli.Int("port", 443)
   cli.check()
   ```
   - check 用于检查命令行参数是否合法，这主要检查必要参数是否传入与传入值是否合法

#### 5. 扩展应用示例
结合HTTP测试：
```yak
target = cli.String("target")
cli.check()

// 先进行协议检测
protoCheck = false
for r in tls.Inspect(target)~ {
    if r.Protocol in ["h2"] {
        protoCheck = true
    }
}

if protoCheck {
    // 使用h2协议发送请求
    rsp = poc.HTTP(`GET / HTTP/2`, 
        poc.host(target),
        poc.https(true)
    )~
    dump(rsp)
}
```

#### 6. 最佳实践建议
1. 优先使用`poc.HTTP`进行请求测试
2. 重要检测逻辑配合`try-catch`：
   ```yak
   try {
       results = tls.Inspect(target)~
   } catch err {
       println("TLS检测失败:", err)
       return
   }
   ```
3. 结合命令行参数：
   ```yak
   target = cli.String("target", "https://example.com")
   timeout = cli.Int("timeout", 5)
   cli.check()
   ```

本教程完整演示了如何利用Yaklang进行协议级安全检测，这些方法可以应用于：
- Web服务器协议兼容性测试
- 中间件安全配置验证
- 漏洞验证前的环境检测
- 自动化安全扫描工具开发