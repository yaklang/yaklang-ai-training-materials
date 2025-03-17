## 在 poc 模块中进行错误处理。

```yak error
// 错误代码
rsp, req = poc.HTTP(`GET / HTTP/1.1
Host: www.example.com

`, poc.https(true)) // 这个代码是错误的，会报错如下：The function call returns (bytes, bytes, error) type, but 2 variables on the left side. 
```

如果遇到 `The function call returns (..., error) type, but 2 variables on the left side.` 这个错误的话，说明函数返回值是 3 个，但是你只接收了 2 个。可以在左值增加一个变量来接收新的值。

```yak
// 接受了错误信息的代码
rsp, req, err = poc.HTTP(`GET / HTTP/1.1
Host: www.example.com

`, poc.https(true))
// 这个代码表面上是正确了，但是如果用户不处理 err 的话，会报错。
// Error: Error Unhandled 
```

`Error Unhandled` 意味着用户没有处理错误，这个不利于程序稳定。简单处理方式是可以 `die(err)`

修复上述代码后，可以参考如下内容：

```yak
// 正确处理错误的代码
rsp, req, err = poc.HTTP(`GET / HTTP/1.1
Host: www.example.com

`, poc.https(true))
die(err) // 如果 err 不为空，则报错。
```

在 poc 模块中，有很多函数都需要这么处理错误，可以参考代码

```
rsp, req, err := poc.HTTPEx(packet)
die(err)
```

除了这种处理方式之外，还有一种简化方式，如果 `rsp, req := poc.HTTPEx(packet)~` 在函数后面加波浪号，这个叫 wavycall 是 yaklang 中特有的语法，可以简化错误处理。

```yak
rsp, req := poc.HTTPEx(packet)~ // 这个代码等价于 `rsp, req, err := poc.HTTPEx(packet)~; die(err)`
```