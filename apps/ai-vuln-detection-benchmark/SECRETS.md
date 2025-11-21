# GitHub Secrets 配置指南

本文档列出了部署 AI Benchmark 系统所需的所有 GitHub Secrets 配置。

## 必需的 Secrets

### 1. 服务器连接相关

#### `EMBEDDING_HOST`
- **说明**: 远程服务器地址
- **格式**: `用户名@服务器地址:端口`
- **示例**: `root@192.168.1.100:22`
- **用途**: SSH 连接目标服务器

#### `EMBEDDING_HOST_PRIVATE_KEY`
- **说明**: SSH 私钥
- **格式**: 完整的 SSH 私钥内容（包括开始和结束标记）
- **示例**:
```
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA...
...（省略中间内容）...
-----END RSA PRIVATE KEY-----
```
- **用途**: SSH 免密登录认证
- **注意事项**:
  - 必须是完整的私钥内容
  - 包含所有换行符
  - 对应的公钥需要添加到服务器的 `~/.ssh/authorized_keys`

### 2. 服务端口配置

#### `AI_BENCHMARK_REPORT_PORT`
- **说明**: Report Viewer Web 服务端口
- **格式**: 数字
- **示例**: `9094`
- **用途**: Report Viewer Web 界面监听端口
- **注意事项**:
  - 端口范围: 1024-65535（建议使用高端口）
  - 确保端口未被占用
  - 如需外网访问，需在防火墙开放此端口

### 3. 测试配置

#### `AI_BENCHMARK_TEST_CONFIG`
- **说明**: 测试配置 JSON
- **格式**: JSON 字符串
- **必需**: ✅ 是
- **示例**:
```json
{
  "testConfigs": [
    {
      "name": "SQLite UNION Injection Test",
      "targetURL": "http://127.0.0.1:8787/user/id?id=1",
      "maxIteration": 10,
      "timeout": 300,
      "taskPrompt": "Your task is to detect SQL injection vulnerabilities...",
      "riskMatchKeywords": ["SQL", "injection", "SQLite", "UNION"]
    }
  ]
}
```
- **用途**: 定义测试场景
- **注意事项**:
  - 必须是有效的 JSON 格式
  - `testConfigs` 是数组，可以包含多个测试场景
  - 每次部署会自动上传到服务器

#### `AI_BENCHMARK_AI_CONFIG`
- **说明**: AI 模型配置 JSON
- **格式**: JSON 字符串
- **必需**: ✅ 是
- **示例**:
```json
{
  "aiConfigs": [
    {
      "provider": "openai",
      "model": "gpt-4",
      "domain": "api.openai.com",
      "apikey": "sk-proj-xxxxx",
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
- **用途**: 定义要测试的 AI 模型
- **注意事项**:
  - 必须是有效的 JSON 格式
  - `aiConfigs` 是数组，可以包含多个模型配置
  - API Key 必须是真实有效的
  - 每次部署会自动上传到服务器

## Secrets 配置步骤

### 在 GitHub 上配置

1. 进入 GitHub 仓库页面
2. 点击 **Settings** 标签
3. 在左侧菜单中选择 **Secrets and variables** → **Actions**
4. 点击 **New repository secret** 按钮
5. 依次添加上述所有 Secret

### 配置检查清单

- [ ] `EMBEDDING_HOST` - 服务器地址
- [ ] `EMBEDDING_HOST_PRIVATE_KEY` - SSH 私钥
- [ ] `AI_BENCHMARK_REPORT_PORT` - Report Viewer 端口
- [ ] `AI_BENCHMARK_TEST_CONFIG` - 测试配置 JSON
- [ ] `AI_BENCHMARK_AI_CONFIG` - AI 模型配置 JSON

## 配置文件格式详解

### TEST_CONFIG 字段说明

```json
{
  "testConfigs": [
    {
      "name": "测试场景名称",
      "targetURL": "目标 URL",
      "maxIteration": 10,           // ReAct 最大迭代次数
      "timeout": 300,                // 超时时间（秒）
      "taskPrompt": "任务提示词...", // 完整的任务描述
      "riskMatchKeywords": [         // 用于匹配 Risk 的关键词
        "SQL",
        "injection"
      ]
    }
  ]
}
```

### AI_CONFIG 字段说明

```json
{
  "aiConfigs": [
    {
      "provider": "提供商",          // openai, aibalance, anthropic 等
      "model": "模型名称",            // gpt-4, claude-3-sonnet 等
      "domain": "API 域名",          // 可选，某些提供商需要
      "apikey": "API 密钥",          // 必需
      "description": "模型描述"      // 用于显示
    }
  ]
}
```

## 验证配置

### 1. 验证 JSON 格式

使用 `jq` 命令验证 JSON 格式：

```bash
# 验证 test-config.json
echo "$AI_BENCHMARK_TEST_CONFIG" | jq .

# 验证 ai-config.json
echo "$AI_BENCHMARK_AI_CONFIG" | jq .
```

### 2. 验证 SSH 连接

```bash
# 测试 SSH 连接
ssh -i /path/to/private_key root@your-server "echo 'Connection successful'"
```

### 3. 验证端口可用性

在服务器上检查端口：

```bash
# 检查端口是否被占用
netstat -tlnp | grep 9094
```

## 安全建议

### 1. SSH 私钥安全

- ✅ 使用专用的部署密钥，不要使用个人密钥
- ✅ 定期轮换密钥
- ✅ 限制密钥权限（只允许必要的操作）
- ❌ 不要在代码或日志中暴露私钥

### 2. API Key 安全

- ✅ 为每个环境使用不同的 API Key
- ✅ 设置 API Key 使用限额
- ✅ 定期检查 API Key 使用情况
- ✅ 及时撤销不再使用的 Key
- ❌ 不要在配置中使用示例 Key

### 3. 配置文件安全

- ✅ 定期审查配置内容
- ✅ 限制可以修改 Secrets 的人员
- ✅ 记录配置变更历史
- ❌ 不要在公开位置分享配置

## 更新配置

### 更新测试配置

1. 在 GitHub Secrets 中修改 `AI_BENCHMARK_TEST_CONFIG`
2. 重新运行部署 Workflow
3. 新配置会自动部署到服务器

### 更新 AI 配置

1. 在 GitHub Secrets 中修改 `AI_BENCHMARK_AI_CONFIG`
2. 重新运行部署 Workflow
3. 新配置会自动部署到服务器

### 更新后验证

部署完成后，检查服务器上的配置文件：

```bash
# 查看测试配置
cat /root/yaklang-ai-training-materials/apps/ai-vuln-detection-benchmark/test-config.json

# 查看 AI 配置
cat /root/yaklang-ai-training-materials/apps/ai-vuln-detection-benchmark/ai-config.json

# 重启服务使配置生效
systemctl restart yak-ai-benchmark
```

## 故障排除

### 配置未生效

**症状**: 部署后配置没有更新

**解决方案**:
1. 检查 Secrets 是否正确设置
2. 查看 GitHub Actions 日志
3. 手动重启服务: `systemctl restart yak-ai-benchmark`

### JSON 格式错误

**症状**: 部署失败，提示 JSON 无效

**解决方案**:
1. 使用在线 JSON 验证工具验证格式
2. 确保没有多余的逗号
3. 确保所有字符串使用双引号
4. 确保没有注释（JSON 不支持注释）

### SSH 连接失败

**症状**: 部署时无法连接服务器

**解决方案**:
1. 验证 `EMBEDDING_HOST` 格式正确
2. 验证私钥格式完整
3. 确保服务器防火墙允许 SSH 连接
4. 检查服务器上的 `authorized_keys` 配置

### API Key 无效

**症状**: 测试执行失败，提示 API 认证错误

**解决方案**:
1. 验证 API Key 是否正确
2. 检查 API Key 是否有足够的配额
3. 确认 API Key 有相应的权限
4. 联系 API 提供商确认状态

## 配置示例

### 完整的配置示例

#### TEST_CONFIG 示例（多场景）

```json
{
  "testConfigs": [
    {
      "name": "SQLite UNION Injection - Basic",
      "targetURL": "http://127.0.0.1:8787/user/id?id=1",
      "maxIteration": 10,
      "timeout": 300,
      "taskPrompt": "Test basic UNION injection...",
      "riskMatchKeywords": ["SQL", "injection", "UNION"]
    },
    {
      "name": "SQLite UNION Injection - Advanced",
      "targetURL": "http://127.0.0.1:8787/user/id?id=1",
      "maxIteration": 15,
      "timeout": 600,
      "taskPrompt": "Test advanced UNION injection with WAF bypass...",
      "riskMatchKeywords": ["SQL", "injection", "bypass"]
    }
  ]
}
```

#### AI_CONFIG 示例（多模型）

```json
{
  "aiConfigs": [
    {
      "provider": "openai",
      "model": "gpt-4",
      "domain": "api.openai.com",
      "apikey": "sk-proj-xxxxx",
      "description": "GPT-4"
    },
    {
      "provider": "openai",
      "model": "gpt-3.5-turbo",
      "domain": "api.openai.com",
      "apikey": "sk-proj-xxxxx",
      "description": "GPT-3.5 Turbo"
    },
    {
      "provider": "aibalance",
      "model": "claude-3-sonnet",
      "domain": "",
      "apikey": "your-key-here",
      "description": "Claude 3 Sonnet"
    },
    {
      "provider": "aibalance",
      "model": "claude-3-opus",
      "domain": "",
      "apikey": "your-key-here",
      "description": "Claude 3 Opus"
    }
  ]
}
```

## 总结

### 必需的 5 个 Secrets

| Secret 名称 | 类型 | 是否必需 | 说明 |
|-------------|------|----------|------|
| `EMBEDDING_HOST` | 字符串 | ✅ 必需 | 服务器地址 |
| `EMBEDDING_HOST_PRIVATE_KEY` | 文本 | ✅ 必需 | SSH 私钥 |
| `AI_BENCHMARK_REPORT_PORT` | 数字 | ✅ 必需 | Web 端口 |
| `AI_BENCHMARK_TEST_CONFIG` | JSON | ✅ 必需 | 测试配置 |
| `AI_BENCHMARK_AI_CONFIG` | JSON | ✅ 必需 | AI 配置 |

### 配置优先级

所有配置都是必需的，缺少任何一个都会导致部署失败。

### 配置更新频率建议

- **服务器连接**: 仅在服务器变更时更新
- **端口配置**: 仅在端口冲突时更新
- **测试配置**: 根据测试需求随时更新
- **AI 配置**: 根据 API Key 轮换或模型变更时更新

## 联系支持

如有配置问题，请：
1. 查看 GitHub Actions 运行日志
2. 检查服务器日志: `journalctl -u yak-ai-benchmark -n 100`
3. 提交 Issue 到 GitHub 仓库

