# 快速开始

## 启动健康检查服务

```bash
# 基础用法（默认端口 8080）
yak apps/health-checking/health-checking.yak

# 自定义配置
yak apps/health-checking/health-checking.yak --port 9090 --interval 60 --timeout 10
```

## 访问界面

### Web 可视化界面
打开浏览器访问：
```
http://localhost:8080
```

### JSON API
获取 JSON 格式的健康数据：
```bash
curl http://localhost:8080/health.json | python3 -m json.tool
```

或使用 YAK 脚本：
```yak
rsp, req, err = poc.HTTP(`GET /health.json HTTP/1.1
Host: localhost:8080

`, poc.host("127.0.0.1"), poc.port(8080))

if err == nil {
    _, body = poc.Split(rsp)
    data = json.loads(body)
    dump(data)
}
```

## 运行测试

```bash
# 启动服务后，在另一个终端运行
yak apps/health-checking/test-health-checking.yak --port 8080
```

## 添加自定义服务

编辑 `health-checking.yak` 文件中的 `serviceConfigs` 数组：

```yak
serviceConfigs = [
    {
        "service_id": "my_service",
        "service_name": "我的服务",
        "service_name_en": "My Service",
        "health_url": "https://example.com/health",
        "method": "GET"
    },
    // 添加更多服务...
]
```

## 示例输出

### JSON API 响应
```json
[
  {
    "service_id": "yaklang",
    "service_name": "YakLang 官网",
    "service_name_en": "YakLang Official",
    "status_code": 200,
    "response": "<!doctype html>...",
    "updated_at": "2025-10-24T23:03:34+08:00"
  }
]
```

### 测试输出
```
[测试 1] 检查服务可访问性...
✓ 服务可访问 (HTTP 200)

[测试 2] 检查 JSON API...
✓ JSON API 工作正常 (包含 3 个服务)

[测试 4] 服务状态详情:
✓ YakLang 官网 (yaklang)
   状态码: 200 - Healthy
   响应: <!doctype html>...
```

## 常见用例

### 1. 后台运行
```bash
nohup yak apps/health-checking/health-checking.yak > health.log 2>&1 &
```

### 2. 定时任务
```bash
# 添加到 crontab
@reboot cd /path/to/yaklang-ai-training-materials && yak apps/health-checking/health-checking.yak
```

### 3. Docker 容器
```dockerfile
FROM yaklang/yak:latest
COPY apps/health-checking /app
WORKDIR /app
CMD ["yak", "health-checking.yak", "--port", "8080"]
```

## 故障排查

### 服务无法启动
检查端口是否被占用：
```bash
lsof -i :8080
```

### HTML 页面显示 MOCK 数据
表示无法连接到后端 `/health.json`，检查：
1. 服务是否正常运行
2. 端口配置是否正确
3. 浏览器控制台查看错误信息

### 健康检查失败
常见原因：
- DNS 解析失败
- 网络不可达
- 目标服务超时
- HTTPS 证书问题

查看详细日志以获取错误信息。

