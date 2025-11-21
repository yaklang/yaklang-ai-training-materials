# AI Benchmark 部署说明

## 概述

本部署脚本会同时部署两个服务：

1. **AI Benchmark 服务** - 执行 AI 模型漏洞检测测试
2. **Report Viewer 服务** - 查看历史测试报告

两个服务共享同一个报告目录，Benchmark 生成报告，Report Viewer 展示报告。

## 部署架构

```
┌──────────────────────────────────────────────────────────────┐
│                    Remote Server                              │
│                                                               │
│  ┌──────────────────────┐      ┌───────────────────────┐    │
│  │  Benchmark Service   │      │  Report Viewer        │    │
│  │  (CLI Mode)          │      │  (Web: Port 9094)     │    │
│  │                      │      │                       │    │
│  │  - 执行测试          │      │  - Web 界面           │    │
│  │  - 生成报告          │      │  - 查看报告           │    │
│  │  - 启动 vulinbox     │      │  - 只读模式           │    │
│  │  - 无 Web 界面       │      │                       │    │
│  └──────────┬───────────┘      └──────────┬────────────┘    │
│             │                              │                 │
│             └──────────┬───────────────────┘                 │
│                        │                                     │
│                        ▼                                     │
│              ┌──────────────────┐                           │
│              │  Report Directory │                           │
│              │  /root/ai-benchmark-reports                  │
│              └──────────────────┘                           │
│                                                               │
│  ┌────────────────────────────────────────────────┐         │
│  │  GitHub Secrets                                │         │
│  │  - test-config.json  → 自动部署                │         │
│  │  - ai-config.json    → 自动部署                │         │
│  └────────────────────────────────────────────────┘         │
└──────────────────────────────────────────────────────────────┘
```

## 前置要求

### GitHub Secrets 配置

需要在 GitHub Repository Settings → Secrets and variables → Actions 中配置以下 secrets：

| Secret 名称 | 说明 | 示例 |
|------------|------|------|
| `EMBEDDING_HOST` | 远程服务器地址 | `root@example.com:22` |
| `EMBEDDING_HOST_PRIVATE_KEY` | SSH 私钥 | `-----BEGIN RSA PRIVATE KEY-----...` |
| `AI_BENCHMARK_REPORT_PORT` | Report Viewer 端口 | `9094` |
| `AI_BENCHMARK_TEST_CONFIG` | 测试配置 JSON（必需） | `{"testConfigs":[...]}` |
| `AI_BENCHMARK_AI_CONFIG` | AI 配置 JSON（必需） | `{"aiConfigs":[...]}` |

#### 配置文件格式

**AI_BENCHMARK_TEST_CONFIG** 示例：
```json
{
  "testConfigs": [
    {
      "name": "SQLite UNION Injection Test",
      "targetURL": "http://127.0.0.1:8787/user/id?id=1",
      "maxIteration": 10,
      "timeout": 300,
      "taskPrompt": "Your task is to detect SQL injection...",
      "riskMatchKeywords": ["SQL", "injection", "SQLite"]
    }
  ]
}
```

**AI_BENCHMARK_AI_CONFIG** 示例：
```json
{
  "aiConfigs": [
    {
      "provider": "openai",
      "model": "gpt-4",
      "domain": "api.openai.com",
      "apikey": "sk-your-api-key-here",
      "description": "GPT-4"
    },
    {
      "provider": "aibalance",
      "model": "claude-3-sonnet",
      "domain": "",
      "apikey": "your-api-key-here",
      "description": "Claude 3 Sonnet"
    }
  ]
}
```

**注意事项：**
- JSON 必须是有效格式，可以先在本地验证：`jq . config.json`
- API Key 应使用真实的密钥，不要使用示例值
- 配置文件会在每次部署时从 Secrets 读取并上传到服务器
- 配置更新后，重新运行部署即可生效

### 服务器要求

- **操作系统**: Ubuntu 22.04 或更高版本
- **权限**: root 或具有 sudo 权限
- **端口**: 确保配置的端口未被占用
- **磁盘空间**: 至少 2GB 可用空间（用于存储报告）
- **网络**: 能够访问 AI API（OpenAI、Claude 等）

## 部署流程

### 1. 手动触发部署

在 GitHub 仓库页面：
1. 点击 **Actions** 标签
2. 选择 **Deploy AI Benchmark** workflow
3. 点击 **Run workflow** 按钮
4. 选择分支（通常是 `main`）
5. 点击 **Run workflow** 确认

### 2. 自动触发部署（可选）

如果需要在代码变更时自动部署，取消注释 `.github/workflows/deploy-ai-benchmark.yml` 中的以下部分：

```yaml
on:
  push:
    branches:
      - main
    paths:
      - 'apps/ai-vuln-detection-benchmark/**'
      - '.github/workflows/deploy-ai-benchmark.yml'
```

## 部署步骤详解

### Step 1: 下载 Yaklang 引擎
- 从官方 OSS 下载指定版本的 yak 引擎
- 验证文件完整性

### Step 2: 准备 SSH 连接
- 配置 SSH 私钥
- 验证私钥格式

### Step 3: 准备环境配置
- 生成 Benchmark 服务配置文件
- 生成 Report Viewer 服务配置文件

### Step 4: 上传文件到服务器
- 上传通用部署脚本
- 上传 systemd 安装脚本
- 上传应用文件（.yak, .html, .json）
- 上传环境配置文件

### Step 5: 部署 Report Viewer 服务
- 使用通用部署脚本安装服务
- 配置 systemd 服务
- 启动服务

### Step 6: 部署 Benchmark 服务
- 使用通用部署脚本安装服务
- 配置 systemd 服务
- 启动服务

### Step 7: 验证部署
- 检查服务状态
- 执行健康检查
- 验证报告目录

## 服务配置

### Benchmark 服务

**服务名称**: `yak-ai-benchmark`

**启动参数**:
```bash
yak ai-model-vuln-detection-benchmark.yak \
  --output-dir $REPORT_DIR \
  --config test-config.json \
  --ai-config ai-config.json
```

**配置文件**:
- `test-config.json` - 测试场景配置（从 GitHub Secrets 自动部署）
- `ai-config.json` - AI 模型配置（从 GitHub Secrets 自动部署）

**运行模式**:
- CLI 模式（无 Web 界面）
- 自动执行所有测试场景
- 每完成一个测试立即保存报告

### Report Viewer 服务

**服务名称**: `yak-ai-benchmark-report-viewer`

**启动参数**:
```bash
yak report-viewer.yak \
  --port $REPORT_VIEWER_PORT \
  --report-dir $REPORT_DIR
```

## 服务管理

### 查看服务状态

```bash
# Report Viewer
systemctl status yak-ai-benchmark-report-viewer

# Benchmark
systemctl status yak-ai-benchmark
```

### 查看服务日志

```bash
# Report Viewer 实时日志
journalctl -u yak-ai-benchmark-report-viewer -f

# Benchmark 实时日志
journalctl -u yak-ai-benchmark -f

# 查看最近 100 行日志
journalctl -u yak-ai-benchmark-report-viewer -n 100
journalctl -u yak-ai-benchmark -n 100
```

### 重启服务

```bash
# 重启 Report Viewer
systemctl restart yak-ai-benchmark-report-viewer

# 重启 Benchmark
systemctl restart yak-ai-benchmark
```

### 停止服务

```bash
# 停止 Report Viewer
systemctl stop yak-ai-benchmark-report-viewer

# 停止 Benchmark
systemctl stop yak-ai-benchmark
```

### 启动服务

```bash
# 启动 Report Viewer
systemctl start yak-ai-benchmark-report-viewer

# 启动 Benchmark
systemctl start yak-ai-benchmark
```

## 配置文件管理

### 更新测试配置

1. SSH 登录到服务器
2. 编辑配置文件：
   ```bash
   cd /root/yaklang-ai-training-materials/apps/ai-vuln-detection-benchmark
   vim test-config.json
   ```
3. 重启 Benchmark 服务：
   ```bash
   systemctl restart yak-ai-benchmark
   ```

### 更新 AI 配置

1. SSH 登录到服务器
2. 编辑配置文件：
   ```bash
   cd /root/yaklang-ai-training-materials/apps/ai-vuln-detection-benchmark
   vim ai-config.json
   ```
3. 重启 Benchmark 服务：
   ```bash
   systemctl restart yak-ai-benchmark
   ```

## 报告管理

### 查看报告

访问 Report Viewer Web 界面：
```
http://your-server-ip:9094
```

### 清理旧报告

```bash
# 删除 7 天前的报告
find /root/ai-benchmark-reports -name "*.json" -mtime +7 -delete

# 只保留最新 100 个报告
cd /root/ai-benchmark-reports
ls -t *.json | tail -n +101 | xargs rm -f
```

### 备份报告

```bash
# 打包所有报告
tar -czf ai-benchmark-reports-$(date +%Y%m%d).tar.gz /root/ai-benchmark-reports/

# 下载到本地
scp root@your-server:/root/ai-benchmark-reports-*.tar.gz ./
```

## 故障排除

### 服务无法启动

1. 检查服务日志：
   ```bash
   journalctl -u yak-ai-benchmark -n 100
   journalctl -u yak-ai-benchmark-report-viewer -n 100
   ```

2. 检查端口占用：
   ```bash
   netstat -tlnp | grep 9093
   netstat -tlnp | grep 9094
   ```

3. 检查配置文件：
   ```bash
   cd /root/yaklang-ai-training-materials/apps/ai-vuln-detection-benchmark
   cat .env.benchmark
   cat .env.report-viewer
   ```

### Benchmark 测试失败

1. 检查 AI API Key 是否正确
2. 检查网络连接是否正常
3. 检查 vulinbox 是否成功启动：
   ```bash
   ps aux | grep vulinbox
   netstat -tlnp | grep 8787
   ```

### Report Viewer 无法显示报告

1. 检查报告目录权限：
   ```bash
   ls -lh /root/ai-benchmark-reports/
   ```

2. 检查报告文件格式：
   ```bash
   cd /root/ai-benchmark-reports
   head -n 20 *.json
   ```

### 部署失败

1. 检查 GitHub Actions 日志
2. 验证 SSH 连接：
   ```bash
   ssh -i /path/to/key root@your-server
   ```
3. 检查服务器磁盘空间：
   ```bash
   df -h
   ```

## 监控和维护

### 定期检查

建议每周执行以下检查：

1. **服务状态**
   ```bash
   systemctl status yak-ai-benchmark yak-ai-benchmark-report-viewer
   ```

2. **磁盘使用**
   ```bash
   du -sh /root/ai-benchmark-reports/
   ```

3. **日志大小**
   ```bash
   journalctl --disk-usage
   ```

4. **清理旧日志**
   ```bash
   journalctl --vacuum-time=7d
   ```

### 性能优化

1. **限制报告数量**: 定期清理旧报告
2. **日志轮转**: 配置 systemd journal 日志轮转
3. **资源限制**: 在 systemd 服务文件中配置 CPU 和内存限制

## 安全建议

1. **防火墙配置**: 只开放必要的端口
2. **反向代理**: 使用 Nginx 作为反向代理，添加 SSL/TLS
3. **访问控制**: 配置 IP 白名单或基本认证
4. **API Key 管理**: 定期轮换 AI API Key
5. **日志审计**: 定期检查访问日志

## 更新和回滚

### 更新服务

重新运行 GitHub Actions workflow 即可自动更新。

### 回滚到之前的版本

1. 在 GitHub Actions 中找到之前成功的部署
2. 重新运行该 workflow

或者手动回滚：

```bash
cd /root/yaklang-ai-training-materials
git checkout <commit-hash>
systemctl restart yak-ai-benchmark yak-ai-benchmark-report-viewer
```

## 联系和支持

如有问题，请：
1. 查看 GitHub Issues
2. 查看服务日志
3. 联系维护团队

## 附录

### 目录结构

```
/root/yaklang-ai-training-materials/
├── apps/
│   ├── deploy-yak-app.sh                          # 通用部署脚本
│   └── ai-vuln-detection-benchmark/
│       ├── ai-model-vuln-detection-benchmark.yak  # Benchmark 主脚本
│       ├── ai-model-vuln-detection-benchmark.html # Benchmark 前端
│       ├── report-viewer.yak                      # Report Viewer 脚本
│       ├── report-viewer.html                     # Report Viewer 前端
│       ├── test-config-example.json               # 测试配置示例
│       ├── ai-config-example.json                 # AI 配置示例
│       ├── .env.benchmark                         # Benchmark 环境变量
│       └── .env.report-viewer                     # Report Viewer 环境变量
├── scripts/
│   └── install-yak-scripts-to-systemd.yak        # Systemd 安装脚本
└── /root/ai-benchmark-reports/                    # 报告目录
    ├── benchmark-report-1234567890.json
    ├── benchmark-report-1234567891.json
    └── ...
```

### 环境变量

#### Benchmark 服务 (.env.benchmark)
```bash
BENCHMARK_PORT=9093
REPORT_DIR=/root/ai-benchmark-reports
```

#### Report Viewer 服务 (.env.report-viewer)
```bash
REPORT_VIEWER_PORT=9094
REPORT_DIR=/root/ai-benchmark-reports
```

### Systemd 服务文件位置

```
/etc/systemd/system/yak-ai-benchmark.service
/etc/systemd/system/yak-ai-benchmark-report-viewer.service
```

