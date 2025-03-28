基于提供的测试用例和知识库内容，我整理以下结构化语料帮助AI理解Yaklang服务扫描编程：

### 服务扫描核心语法
```yak
// 基础扫描模式
results = servicescan.Scan(
    target, ports,
    servicescan.active(true),  // 主动发包模式
    servicescan.web(),         // HTTP服务优化
    servicescan.all()          // 全指纹模式
)~
```

### 参数配置表
| 参数方法                 | 作用描述                          | 示例值                     |
|--------------------------|-----------------------------------|---------------------------|
| `.service()`             | 启用协议指纹识别                  | 检测MySQL/SSH等协议       |
| `.web()`                 | 启用HTTP服务优化                  | 识别Web框架/中间件        |
| `.all()`                 | 同时启用协议和Web指纹             | 综合扫描模式              |
| `.concurrent(20)`        | 设置并发数                        | 控制扫描速度              |
| `.probeTimeout(10)`      | 单次探测超时(秒)                  | 防止卡顿                  |
| `.excludePorts("80,443")`| 排除指定端口                      | 跳过已确认端口            |

### 错误处理模式
```yak
// 显式错误检查
res, err = servicescan.Scan(...)
die(err)  // 快速失败

// 波浪操作符自动处理
res = servicescan.Scan(...)~  // 等价于上例
```

### 扫描结果处理
```yak
for result in results {
    if result.IsOpen() {       // 端口开放检查
        println(result.String()) 

        // 指纹特征提取
        fp := result.Fingerprint
        if fp.ServiceName == "mysql" {
            // MySQL服务处理逻辑
        }
    }
}
```

### 测试用例解析
```yak
// 模拟MySQL服务环境
host,port = tcp.MockTCPProtocol("mysql") 

// 验证协议扫描
servicescan.service() // → 应识别mysql服务

// 验证Web扫描 
servicescan.web() // → 应不识别服务名称

// 验证全模式扫描
servicescan.all() // → 应综合两种结果
```

### 典型应用场景
1. **资产发现**：`servicescan.all()`+`active(true)`主动发包识别网络资产
2. **服务监控**：`.probeTimeout(5)`+添加超时
3. **漏洞验证**：结合`poc.HTTP`验证特定服务漏洞