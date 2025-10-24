# YAK Services Health Checking

一个优雅的服务健康检查和监控系统，提供实时的服务状态展示和 JSON API 接口。

## 功能特性

- 🚀 **实时监控**: 定期检查配置的服务健康状态
- 📊 **可视化展示**: 美观的 Web 界面展示服务状态
- 🔄 **自动刷新**: 前端每 30 秒自动刷新状态
- 📡 **JSON API**: 提供标准的 JSON 接口供其他系统调用
- 🔒 **线程安全**: 使用互斥锁保证并发安全
- ⚡ **高性能**: 基于 YAK 引擎的高效 HTTP 服务器

## 快速开始

### 基础用法

```bash
# 使用默认配置启动（端口 8080，检查间隔 60 秒）
yak apps/health-checking/health-checking.yak

# 自定义端口和检查间隔
yak apps/health-checking/health-checking.yak --port 9090 --interval 30

# 设置请求超时时间
yak apps/health-checking/health-checking.yak --timeout 15
```

### 命令行参数

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `--port` | 监控服务监听端口 | 8080 |
| `--interval` | 健康检查间隔（秒） | 60 |
| `--timeout` | HTTP 请求超时时间（秒） | 10 |

## 访问界面

启动服务后，可以通过以下方式访问：

### Web 界面
```
http://localhost:8080
```

访问主页面查看美观的服务健康状态可视化界面。

### JSON API
```
http://localhost:8080/health.json
```

获取 JSON 格式的服务健康数据，适合程序调用。

## 服务配置

在 `health-checking.yak` 文件中的 `serviceConfigs` 数组中配置需要监控的服务：

```javascript
serviceConfigs = [
    {
        "service_id": "aibalance",
        "service_name": "AI均衡器",
        "service_name_en": "AI Balance",
        "health_url": "https://ai.yaklang.com/health",
        "method": "GET"
    },
    // 添加更多服务...
]
```

### 配置字段说明

- `service_id`: 服务唯一标识符
- `service_name`: 服务中文名称
- `service_name_en`: 服务英文名称
- `health_url`: 健康检查的 URL 地址
- `method`: HTTP 请求方法（默认 GET）

## JSON 数据格式

### 响应示例

```json
[
  {
    "service_id": "aibalance",
    "service_name": "AI均衡器",
    "service_name_en": "AI Balance",
    "status_code": 200,
    "response": "OK",
    "updated_at": "2024-01-01T12:00:00Z"
  },
  {
    "service_id": "yakengine",
    "service_name": "YAK引擎",
    "service_name_en": "YAK Engine",
    "status_code": 200,
    "response": "<!DOCTYPE html>...",
    "updated_at": "2024-01-01T12:00:05Z"
  }
]
```

### 字段说明

- `service_id`: 服务 ID
- `service_name`: 服务中文名称
- `service_name_en`: 服务英文名称
- `status_code`: HTTP 响应状态码（200 表示健康）
- `response`: 响应内容摘要（截取前 200 字符）
- `updated_at`: 最后更新时间（ISO 8601 格式）

## 健康状态判断

服务健康状态基于 HTTP 状态码判断：

- ✅ **Healthy**: 状态码 200-299
- ❌ **Unhealthy**: 状态码 < 200 或 >= 300

## 技术架构

### 核心技术栈

- **httpserver**: YAK 内置的 HTTP 服务器
- **poc**: 用于发起 HTTP/HTTPS 健康检查请求
- **sync.Mutex**: 保证并发安全的数据访问
- **json**: JSON 序列化和反序列化
- **time**: 时间戳记录

### 工作流程

1. **初始化**: 加载服务配置，初始化数据存储
2. **首次检查**: 启动时立即执行一次健康检查
3. **定时任务**: 后台协程定期执行健康检查
4. **HTTP 服务**: 提供 Web 界面和 JSON API
5. **数据更新**: 检查结果通过互斥锁安全更新

### 文件结构

```
apps/health-checking/
├── health-checking.yak    # 主程序脚本
├── index.html             # Web 展示界面
└── README.md             # 说明文档
```

## 使用场景

- **服务监控**: 实时监控多个服务的健康状态
- **运维看板**: 提供可视化的服务状态展示
- **集成监控**: 通过 JSON API 集成到其他监控系统
- **健康检查**: 定期检查服务可用性

## 示例：集成到其他系统

### 使用 curl 获取健康数据

```bash
curl http://localhost:8080/health.json | jq .
```

### 使用 YAK 脚本调用

```javascript
// 获取健康数据
rsp, _, err = poc.Get("http://localhost:8080/health.json")
if err == nil {
    _, body = poc.Split(rsp)
    healthData = json.loads(body)
    
    for service in healthData {
        println(f"${service['service_name']}: ${service['status_code']}")
    }
}
```

## 日志输出

脚本运行时会输出详细的日志信息：

```
[INFO] Starting YAK Services Health Checking System...
[INFO] Configuration:
[INFO]   Port: 8080
[INFO]   Check Interval: 60 seconds
[INFO]   Request Timeout: 10 seconds
[INFO] Configured 4 services for monitoring
[INFO] Starting health check scheduler (interval: 60 seconds)

[2024-01-01 12:00:00] 开始健康检查...
[INFO] Checking health for service: aibalance
[INFO] Sending GET request to ai.yaklang.com:443/health (HTTPS: true)
[INFO] Health check completed for aibalance: status=200
  ✓ AI均衡器 (aibalance): 200
  ✓ YAK引擎 (yakengine): 200
  ✓ YakIt客户端 (yakit): 200
  ✓ AI知识库 (aikb): 200
健康检查完成
```

## 注意事项

1. **HTTPS 支持**: 自动识别 HTTPS 协议，无需额外配置
2. **超时设置**: 合理设置超时时间，避免检查时间过长
3. **检查间隔**: 建议间隔时间不少于 30 秒，避免频繁请求
4. **并发安全**: 使用了互斥锁保证数据访问安全
5. **响应长度**: 响应内容限制在 200 字符以内

## 常见问题

### Q: 如何添加新的监控服务？

A: 在 `serviceConfigs` 数组中添加新的服务配置对象即可。

### Q: 支持 POST 请求吗？

A: 支持，在服务配置中设置 `"method": "POST"` 即可。

### Q: 如何修改前端自动刷新间隔？

A: 编辑 `index.html` 文件，修改 `setInterval(fetchHealthData, 30000)` 中的时间（毫秒）。

### Q: 服务状态码为 0 是什么意思？

A: 表示请求失败或发生异常，可以查看 `response` 字段了解具体错误。

## 开发和扩展

### 自定义健康检查逻辑

可以修改 `checkServiceHealth` 函数来实现自定义的健康检查逻辑：

```javascript
checkServiceHealth = func(config) {
    // 自定义检查逻辑
    // 例如：检查响应内容、验证特定字段等
}
```

### 添加告警功能

可以在健康检查完成后添加告警逻辑：

```javascript
performHealthChecks = func() {
    // ... 执行健康检查
    
    // 检查是否有服务不健康
    for status in newHealthData {
        if status["status_code"] < 200 || status["status_code"] >= 300 {
            // 发送告警（邮件、Webhook 等）
            log.warn("Service unhealthy: %s", status["service_name"])
        }
    }
}
```

## 许可证

本项目遵循与 yaklang-ai-training-materials 仓库相同的许可证。

## 相关链接

- [YAK 官网](https://www.yaklang.com)
- [YakIt 客户端](https://yakit.io)
- [YAK 文档](https://www.yaklang.com/docs)

