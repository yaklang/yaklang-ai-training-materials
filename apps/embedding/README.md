# YAK Embedding Service 部署文档

## 概述

本目录包含 YAK Embedding 服务的自动化部署配置，使用 GitHub Actions 实现 CI/CD。

## 架构说明

```
yaklang-ai-training-materials/
├── .github/workflows/
│   └── deploy-yak-embedding-service.yml    # GitHub Actions 部署工作流
├── apps/embedding/
│   ├── deploy-embedding.sh                 # 部署脚本（在服务器上执行）
│   ├── install-certs.sh                    # SSL/TLS 证书安装脚本
│   ├── .env                                # 配置文件（自动生成）
│   ├── .gitignore                          # Git 忽略规则
│   ├── README.md                           # 本文档（完整部署文档）
│   ├── QUICK_START.md                      # 快速开始指南
│   └── DEPLOYMENT_CHECKLIST.md             # 部署检查清单
└── scripts/
    ├── start-yak-embedding-service.yak     # Embedding 服务启动脚本
    ├── install-yak-scripts-to-systemd.yak  # Systemd 服务安装脚本
    └── test-yak-embedding-rag-service.yak  # 服务测试脚本
```

## 部署流程

### 1. 自动部署（推荐）

当以下文件有改动时，GitHub Actions 会自动触发部署：

- `scripts/start-yak-embedding-service.yak`
- `scripts/install-yak-scripts-to-systemd.yak`
- `apps/embedding/deploy-embedding.sh`
- `.github/workflows/deploy-yak-embedding-service.yml`

也可以在 GitHub Actions 页面手动触发部署。

### 2. 配置 GitHub Secrets

在 GitHub 仓库设置中配置以下 Secrets：

#### 必需的 Secrets

| Secret 名称 | 说明 | 示例 |
|------------|------|------|
| `EMBEDDING_HOST` | 服务器地址（支持 SSH 格式） | `root@192.168.1.100` 或 `user@example.com:22` |
| `EMBEDDING_HOST_PRIVATE_KEY` | SSH 私钥（完整内容） | `-----BEGIN RSA PRIVATE KEY-----\n...` |
| `EMBEDDING_PORT` | 服务监听端口 | `9099` |
| `TOTP_SECRET` | TOTP 验证密钥 | `your-secret-key-here` |

#### 配置步骤

1. 进入 GitHub 仓库
2. 点击 `Settings` > `Secrets and variables` > `Actions`
3. 点击 `New repository secret`
4. 添加上述 Secrets

### 3. 手动部署

如需手动部署，可以在本地执行：

```bash
# 1. 准备配置文件
cat > apps/embedding/.env << EOF
EMBEDDING_PORT=9099
TOTP_SECRET=your-secret-key
EOF

# 2. 上传文件到服务器
scp -i ~/.ssh/id_rsa scripts/start-yak-embedding-service.yak root@server:/root/yaklang-ai-training-materials/scripts/
scp -i ~/.ssh/id_rsa scripts/install-yak-scripts-to-systemd.yak root@server:/root/yaklang-ai-training-materials/scripts/
scp -i ~/.ssh/id_rsa apps/embedding/deploy-embedding.sh root@server:/root/yaklang-ai-training-materials/apps/embedding/
scp -i ~/.ssh/id_rsa apps/embedding/.env root@server:/root/yaklang-ai-training-materials/apps/embedding/

# 3. 在服务器上执行部署
ssh -i ~/.ssh/id_rsa root@server "bash /root/yaklang-ai-training-materials/apps/embedding/deploy-embedding.sh"
```

## 部署脚本功能

`deploy-embedding.sh` 脚本会自动执行以下步骤：

1. ✅ **检查必要文件** - 验证启动脚本、安装脚本和配置文件是否存在
2. ✅ **读取配置** - 从 `.env` 文件加载端口和 TOTP 密钥配置
3. ✅ **安装 YAK 引擎** - 如果不存在，自动下载并安装 YAK 引擎
4. ✅ **停止现有服务** - 优雅停止旧版本服务（如果运行中）
5. ✅ **安装 systemd 服务** - 使用 `install-yak-scripts-to-systemd.yak` 安装服务
6. ✅ **启动服务** - 启动新版本服务并启用开机自启动
7. ✅ **验证部署** - 检查服务状态和端口监听

## SSL/TLS 证书配置（可选但推荐）

为了通过 HTTPS 和域名访问服务（与 Health Checking 服务保持一致），部署完成后可以配置 SSL/TLS 证书。

### 1. 准备工作

确保：
- 域名 DNS 已配置指向服务器 IP
- 服务器防火墙开放 80 和 443 端口
- Embedding 服务已成功部署并运行

### 2. 使用自动化脚本安装证书

SSH 登录服务器后执行：

```bash
# 进入部署目录
cd /root/yaklang-ai-training-materials/apps/embedding

# 交互式安装（会提示输入配置）
bash install-certs.sh

# 或使用非交互式模式（推荐）
bash install-certs.sh \
  --domain your-embedding-domain.com \
  --port 9099 \
  --email admin@example.com \
  --yes
```

### 3. 脚本功能说明

`install-certs.sh` 会自动完成：

- ✅ 安装必需组件（nginx、acme.sh、cron 等）
- ✅ 签发 Let's Encrypt SSL 证书
- ✅ 配置 Nginx 反向代理（HTTP + HTTPS）
- ✅ 设置自动证书续期（每周日检查）
- ✅ 配置 CORS 和 WebSocket 支持
- ✅ 创建证书管理工具 `ssl-manager`

### 4. 证书管理

```bash
# 查看证书状态
ssl-manager status

# 手动续期证书
ssl-manager renew

# 查看 Nginx 配置
cat /etc/nginx/sites-available/your-embedding-domain.com.conf

# 测试 Nginx 配置
nginx -t

# 重新加载 Nginx
systemctl reload nginx
```

### 5. 访问方式对比

配置证书后，服务支持多种访问方式：

| 访问方式 | URL | 说明 |
|---------|-----|------|
| 本地直连 | `http://127.0.0.1:9099` | 服务器本地访问 |
| HTTP | `http://your-domain.com` | 通过域名 HTTP 访问 |
| HTTPS | `https://your-domain.com` | 通过域名 HTTPS 访问（推荐） |

### 6. 与 Health Checking 服务对比

完成证书配置后，Embedding 服务将具备与 Health Checking 服务相同的特性：

| 特性 | Health Checking | Embedding Service |
|------|----------------|-------------------|
| Systemd 自动管理 | ✅ | ✅ |
| TOTP 安全认证 | ✅ | ✅ |
| SSL/TLS 加密 | ✅ | ✅（需运行脚本） |
| Nginx 反向代理 | ✅ | ✅（需运行脚本） |
| 证书自动续期 | ✅ | ✅（需运行脚本） |
| HTTP/HTTPS 双协议 | ✅ | ✅（需运行脚本） |
| CORS 跨域支持 | ✅ | ✅（需运行脚本） |
| WebSocket 支持 | ✅ | ✅（需运行脚本） |

## 服务管理

部署完成后，可以使用以下命令管理服务：

```bash
# 查看服务状态
systemctl status yak-embedding-service

# 查看实时日志
journalctl -u yak-embedding-service -f

# 查看最近日志
journalctl -u yak-embedding-service -n 100

# 重启服务
systemctl restart yak-embedding-service

# 停止服务
systemctl stop yak-embedding-service

# 启动服务
systemctl start yak-embedding-service

# 禁用开机自启动
systemctl disable yak-embedding-service

# 启用开机自启动
systemctl enable yak-embedding-service
```

## 服务测试

### 1. 健康检查

```bash
# 检查服务是否在运行
curl http://127.0.0.1:9099/health
```

### 2. 使用测试脚本

```bash
# 在服务器上运行测试脚本
cd /root/yaklang-ai-training-materials
yak scripts/test-yak-embedding-rag-service.yak
```

### 3. 完整功能测试

测试脚本会验证：
- ✅ 服务是否正常响应
- ✅ TOTP 认证是否工作
- ✅ Embedding 功能是否正常
- ✅ 并发处理能力

## 故障排查

### 服务无法启动

1. 查看服务日志：
```bash
journalctl -u yak-embedding-service -n 100 --no-pager
```

2. 检查配置文件：
```bash
cat /root/yaklang-ai-training-materials/apps/embedding/.env
```

3. 手动测试启动脚本：
```bash
cd /root/yaklang-ai-training-materials
yak scripts/start-yak-embedding-service.yak --port 9099 --totp-secret "your-secret"
```

### 端口被占用

```bash
# 查看端口占用情况
netstat -tuln | grep 9099
# 或
ss -tuln | grep 9099

# 查找占用端口的进程
lsof -i :9099
```

### TOTP 认证失败

1. 确认 TOTP 密钥配置正确
2. 检查服务器时间是否同步（TOTP 依赖时间）：
```bash
timedatectl status
# 如需同步时间
ntpdate -u pool.ntp.org
```

### 部署失败

1. 检查 GitHub Actions 日志
2. 验证 SSH 连接：
```bash
ssh -i /path/to/key root@server "echo 'Connection OK'"
```
3. 确认服务器磁盘空间：
```bash
df -h
```

## 配置说明

### 端口配置

默认端口：`9099`

可通过修改 `EMBEDDING_PORT` Secret 更改。

### TOTP 配置

TOTP 密钥用于客户端身份验证，确保服务安全。

生成新的 TOTP 密钥：
```bash
openssl rand -base64 32
```

### 并发配置

默认并发数：`5`

如需修改，编辑 `deploy-embedding.sh` 中的 `--concurrent` 参数。

## 安全建议

1. ✅ **使用强 TOTP 密钥** - 至少 32 字符的随机字符串
2. ✅ **限制 SSH 访问** - 仅允许必要的 IP 地址访问
3. ✅ **定期更新密钥** - 定期轮换 TOTP 密钥
4. ✅ **监控服务日志** - 定期检查异常访问
5. ✅ **防火墙配置** - 仅开放必要端口

## 性能优化

### 并发数调整

根据服务器配置调整并发数：

- **低配置（2核4G）**: `--concurrent 3`
- **中配置（4核8G）**: `--concurrent 5`（默认）
- **高配置（8核16G+）**: `--concurrent 10`

### 资源监控

```bash
# 查看服务资源使用
systemctl status yak-embedding-service

# 查看进程详细信息
ps aux | grep yak

# 监控系统资源
htop
```

## 更新和维护

### 更新服务

1. 修改相关脚本文件
2. 提交到 main 分支
3. GitHub Actions 自动部署
4. 验证服务正常运行

### 回滚操作

如果新版本有问题，可以：

1. 回退 Git 提交
2. 手动触发 GitHub Actions 部署旧版本
3. 或在服务器上手动恢复旧版本脚本

## 联系方式

如有问题，请提 Issue 或联系维护团队。

---

**版本**: 1.0.0  
**最后更新**: 2025-10-29  
**维护者**: YakLang Team

