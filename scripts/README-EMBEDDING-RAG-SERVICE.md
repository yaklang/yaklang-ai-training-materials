# Yak Embedding RAG Service with TOTP Authentication

基于 RAG 系统的安全 Embedding 服务，支持 TOTP 身份验证和并发控制。

## 📋 目录

- [概述](#概述)
- [核心特性](#核心特性)
- [架构设计](#架构设计)
- [快速开始](#快速开始)
- [脚本说明](#脚本说明)
- [测试验证](#测试验证)
- [技术细节](#技术细节)

## 🎯 概述

这是一个完整的 Embedding 服务解决方案，使用 Yaklang 的 RAG 系统自动管理 embedder 生命周期，提供带 TOTP 验证的安全 API 接口，并支持并发控制以保护服务稳定性。

### 主要改进

1. **使用 RAG 系统管理 embedder**
   - 不再手动管理 llama-server 地址和端口
   - RAG 系统自动启动和管理 embedder 服务
   - 自动处理模型加载和资源分配

2. **并发控制**
   - 使用 `sync.NewSizedWaitGroup` 限制并发 embedding 调用
   - 避免服务过载，保护稳定性
   - 可配置的并发限制（默认 5）

3. **依赖安装流程优化**
   - 自动检查并安装 llama-server
   - 自动检查并安装 embedding 模型
   - 初始化并测试 embedder 可用性

## ✨ 核心特性

### 1. 自动依赖管理

```bash
# 脚本会自动完成以下步骤：
1. 安装 llama-server（如果未安装）
2. 安装 model-Qwen3-Embedding-0.6B-Q4（如果未安装）
3. 初始化 RAG 系统
4. 测试 embedder 是否可用
```

### 2. TOTP 身份验证

- 使用 UTC 时间确保客户端和服务端时间一致
- 6 位数字验证码，每 30 秒更新
- 通过 `X-TOTP-Code` 请求头传递

### 3. 并发控制

- 使用 `sync.NewSizedWaitGroup` 限制并发数量
- 达到限制时自动等待，不会拒绝请求
- 保护 embedder 服务不会过载

### 4. OpenAI API 兼容

响应格式兼容 OpenAI Embedding API：

```json
{
  "object": "list",
  "data": [
    {
      "object": "embedding",
      "embedding": [0.1, 0.2, ...],
      "index": 0
    }
  ],
  "model": "embedding",
  "usage": {
    "prompt_tokens": 13,
    "total_tokens": 13
  }
}
```

## 🏗️ 架构设计

```
┌─────────────────────────────────────────┐
│     Client (connect-yak-embedding)      │
│  - 生成 TOTP 验证码                      │
│  - 发送 embedding 请求                   │
└──────────────┬──────────────────────────┘
               │ HTTP + TOTP
               ▼
┌─────────────────────────────────────────┐
│   HTTP Server (start-yak-embedding)     │
│  - 验证 TOTP                             │
│  - 并发控制 (sync.NewSizedWaitGroup)    │
│  - 转发到 embedder                       │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│        RAG System (rag.GetCollection)   │
│  - 自动管理 embedder 生命周期            │
│  - embedder.Embedding(text)             │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│       llama-server (本地模型服务)        │
│  - Qwen3-Embedding-0.6B-Q4_K_M          │
│  - 自动启动和管理                        │
└─────────────────────────────────────────┘
```

## 🚀 快速开始

### 1. 启动服务

```bash
# 使用新版本的 yak（确保已重新编译）
yak scripts/start-yak-embedding-service.yak \
  --port 9099 \
  --totp-secret my-secret-key \
  --concurrent 5
```

**参数说明：**
- `--port`: 服务监听端口（默认 9099）
- `--totp-secret`: TOTP 验证密钥（必填，需与客户端一致）
- `--concurrent`: 并发限制数量（默认 5）

### 2. 使用客户端

```bash
yak scripts/connect-yak-embedding-totp-service.yak \
  --host 127.0.0.1 \
  --port 9099 \
  --totp-secret my-secret-key \
  --text "Hello, World!"
```

### 3. 手动测试

```bash
# 生成 TOTP 码（可以使用任何 TOTP 工具）
# 然后使用 curl 测试
curl -X POST http://localhost:9099/embeddings \
  -H 'Content-Type: application/json' \
  -H 'X-TOTP-Code: 123456' \
  -d '{"input": "test text"}'
```

## 📜 脚本说明

### 1. start-yak-embedding-service.yak

**主服务端脚本**

- **功能**: 启动带 TOTP 验证和并发控制的 embedding 服务
- **依赖**: 自动安装 llama-server 和 embedding 模型
- **端点**: `POST /embeddings`
- **关键技术**:
  - `rag.GetCollection("default")`: 获取 RAG 系统
  - `ragSystem.Embedder`: 获取 embedder
  - `sync.NewSizedWaitGroup(concurrent)`: 并发控制
  - `twofa.VerifyUTCCode()`: TOTP 验证

### 2. connect-yak-embedding-totp-service.yak

**客户端脚本**

- **功能**: 连接 embedding 服务并发送请求
- **关键技术**:
  - `twofa.GetUTCCode()`: 生成 TOTP 验证码
  - `poc.HTTP()`: 发送 HTTP 请求
  - `json.loads/dumps()`: JSON 处理

### 3. test-yak-embedding-rag-service.yak

**完整功能测试脚本**

- **测试覆盖**:
  - RAG 系统初始化
  - Embedder 可用性
  - HTTP 服务器启动
  - TOTP 验证（有效/无效/缺失）
  - Embedding 请求处理
  - 错误场景处理

### 4. test-final-embedding-service.yak

**端到端集成测试**

- **测试场景**:
  - 单个请求处理
  - 多个顺序请求
  - 并发请求（超过并发限制）
  - TOTP 验证
  - 响应格式验证

## ✅ 测试验证

所有脚本都经过完整的测试验证：

### 测试结果

```
=== Test Summary ===
✓ RAG 系统初始化成功
✓ Embedding 服务启动成功
✓ TOTP 验证工作正常
✓ 单个请求处理正确
✓ 并发控制工作正常

所有测试通过！服务可以正常使用。
```

### 运行测试

```bash
# 测试 RAG embedding 服务的所有功能
yak scripts/test-yak-embedding-rag-service.yak

# 测试完整的端到端流程（包括并发）
yak scripts/test-final-embedding-service.yak
```

## 🔧 技术细节

### RAG 系统集成

```yak
// 获取 RAG 集合
ragSystem, err = rag.GetCollection("default")
if err != nil {
    die(f"Failed to get RAG collection: ${err}")
}

// 获取 embedder
embedder = ragSystem.Embedder

// 使用 embedder
vectors, err = embedder.Embedding("text to embed")
```

### 并发控制实现

```yak
// 创建大小受限的 WaitGroup
swg = sync.NewSizedWaitGroup(concurrent)

// 在请求处理中使用
swg.Add()  // 获取槽位（如果满了会等待）

// 调用 embedder
vectors, err = embedder.Embedding(inputText)

// 立即释放槽位
swg.Done()
```

### TOTP 验证流程

**服务端验证：**
```yak
// 获取 TOTP 码
totpCode = req.Header.Get("X-TOTP-Code")

// 验证（使用 UTC 时间）
if !twofa.VerifyUTCCode(totpSecret, totpCode) {
    // 验证失败
    rsp.WriteHeader(401)
    return
}
```

**客户端生成：**
```yak
// 生成当前 UTC 时间的 TOTP 码
totpCode = twofa.GetUTCCode(totpSecret)

// 添加到请求头
X-TOTP-Code: ${totpCode}
```

## 📚 相关文档

- `library-usage/httpserver/httpserver-practice.yak`: HTTP 服务器用法示例
- `library-usage/twofa/twofa-practice.yak`: TOTP/2FA 用法示例

## 🔄 从旧版本迁移

如果你使用的是旧版本（手动管理 llama-server），请注意以下变更：

### 移除的参数

- `--llama-port`: 不再需要，RAG 系统自动管理

### 新增的参数

- `--concurrent`: 并发限制（默认 5）

### 代码变更

**旧版本（手动管理）：**
```yak
// 手动转发到 llama-server
rsp = poc.HTTP(..., poc.host("127.0.0.1"), poc.port(llamaPort))
```

**新版本（RAG 管理）：**
```yak
// 使用 RAG embedder
ragSystem, _ = rag.GetCollection("default")
vectors, _ = ragSystem.Embedder.Embedding(text)
```

## 🎉 总结

这个重构版本提供了：

1. ✅ 更简单的架构（RAG 自动管理 embedder）
2. ✅ 更好的稳定性（并发控制）
3. ✅ 更容易维护（无需手动管理服务地址）
4. ✅ 完整的测试覆盖
5. ✅ 详细的文档

所有脚本都经过验证，可以直接使用！

