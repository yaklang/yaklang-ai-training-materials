# YAK Embedding Service 快速开始指南

## 🚀 5分钟快速部署

### 步骤 1: 配置 GitHub Secrets

在 GitHub 仓库设置中添加以下 Secrets（Settings > Secrets and variables > Actions）：

```
EMBEDDING_HOST=root@your-server-ip
EMBEDDING_HOST_PRIVATE_KEY=-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA...
(完整的 SSH 私钥内容)
...
-----END RSA PRIVATE KEY-----

EMBEDDING_PORT=9099
TOTP_SECRET=your-32-character-secret-key
```

### 步骤 2: 触发部署

有两种方式触发部署：

#### 方式 1: 推送代码（自动）
修改以下任意文件并推送到 main 分支：
- `scripts/start-yak-embedding-service.yak`
- `scripts/install-yak-scripts-to-systemd.yak`
- `apps/embedding/deploy-embedding.sh`
- `.github/workflows/deploy-yak-embedding-service.yml`

#### 方式 2: 手动触发
1. 进入 GitHub Actions 页面
2. 选择 "Deploy YAK Embedding Service"
3. 点击 "Run workflow"
4. 选择 branch: main
5. 点击 "Run workflow" 按钮

### 步骤 3: 验证部署

部署完成后，SSH 登录服务器验证：

```bash
# 检查服务状态
systemctl status yak-embedding-service

# 查看服务日志
journalctl -u yak-embedding-service -f

# 测试服务（需要配置 TOTP）
curl http://127.0.0.1:9099/health
```

### 步骤 4: 配置 SSL/TLS 证书和 Nginx（可选但推荐）

如果需要通过 HTTPS 和域名访问服务（与 health checking 服务一样），请执行以下步骤：

#### 4.1 准备域名和 DNS

确保域名 DNS 已配置指向服务器 IP：
```bash
# 验证 DNS 解析
nslookup your-embedding-domain.com
dig your-embedding-domain.com
```

#### 4.2 使用证书安装脚本

```bash
# SSH 登录服务器
ssh root@your-server-ip

# 进入部署目录
cd /root/yaklang-ai-training-materials/apps/embedding

# 运行证书安装脚本（交互式）
bash install-certs.sh

# 或使用非交互式模式（推荐用于自动化）
bash install-certs.sh \
  --domain your-embedding-domain.com \
  --port 9099 \
  --email admin@example.com \
  --yes
```

#### 4.3 脚本会自动完成

- ✅ 安装 nginx、acme.sh 等必需组件
- ✅ 使用 Let's Encrypt 签发免费 SSL 证书
- ✅ 配置 Nginx 反向代理（支持 HTTP/HTTPS）
- ✅ 设置证书自动续期（每周检查）
- ✅ 配置 CORS 和 WebSocket 支持

#### 4.4 验证 HTTPS 访问

```bash
# 测试 HTTP 访问
curl http://your-embedding-domain.com/health

# 测试 HTTPS 访问
curl https://your-embedding-domain.com/health

# 检查证书状态
ssl-manager status

# 手动续期证书（如需要）
ssl-manager renew
```

#### 4.5 防火墙配置

确保开放必要端口：

```bash
# 查看防火墙状态
ufw status  # Ubuntu/Debian
firewall-cmd --list-all  # RHEL/CentOS

# 开放 HTTP 和 HTTPS 端口
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 9099/tcp  # 如果需要直接访问

# 或使用 firewalld
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --permanent --add-port=9099/tcp
firewall-cmd --reload
```

#### 4.6 配置与 Health Checking 服务一致

完成上述步骤后，Embedding 服务将具备与 Health Checking 服务相同的特性：

| 特性 | Health Checking | Embedding Service | 状态 |
|------|----------------|-------------------|------|
| Systemd 服务 | ✅ | ✅ | 已配置 |
| TOTP 认证 | ✅ | ✅ | 已配置 |
| SSL/TLS 证书 | ✅ | ✅ | 需手动运行脚本 |
| Nginx 反向代理 | ✅ | ✅ | 需手动运行脚本 |
| 自动证书续期 | ✅ | ✅ | 需手动运行脚本 |
| HTTP/HTTPS 访问 | ✅ | ✅ | 需手动运行脚本 |
| CORS 支持 | ✅ | ✅ | 需手动运行脚本 |
| WebSocket 支持 | ✅ | ✅ | 需手动运行脚本 |

**注意**: SSL/TLS 和 Nginx 配置需要手动运行 `install-certs.sh` 脚本完成。

## 🔧 配置说明

### 生成 TOTP 密钥

```bash
openssl rand -base64 32
```

### SSH 私钥格式

确保私钥格式正确，包含完整的头尾：

```
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA...
(多行私钥内容)
...
-----END RSA PRIVATE KEY-----
```

### 服务器要求

- **操作系统**: Linux (支持 systemd)
- **最低配置**: 2核4G内存
- **推荐配置**: 4核8G内存或更高
- **必需端口**: 配置的 EMBEDDING_PORT (默认 9099)
- **SSH 访问**: 需要 root 或具有 sudo 权限的用户

## 📊 监控服务

### 实时监控命令

```bash
# 查看服务状态
watch -n 2 'systemctl status yak-embedding-service'

# 实时日志
journalctl -u yak-embedding-service -f --lines=50

# 资源使用
htop
```

### 端口检查

```bash
# 检查端口监听
netstat -tuln | grep 9099
# 或
ss -tuln | grep 9099
```

## 🔒 安全配置

### 1. 防火墙配置

```bash
# 如果使用 ufw
ufw allow 9099/tcp

# 如果使用 firewalld
firewall-cmd --permanent --add-port=9099/tcp
firewall-cmd --reload
```

### 2. 限制访问 IP

在防火墙中限制只允许特定 IP 访问：

```bash
# ufw 示例
ufw allow from 192.168.1.0/24 to any port 9099

# firewalld 示例
firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="192.168.1.0/24" port protocol="tcp" port="9099" accept'
```

### 3. TOTP 密钥管理

- ✅ 使用强随机密钥（至少 32 字符）
- ✅ 定期更新密钥（建议每季度）
- ✅ 妥善保管密钥，不要提交到代码仓库
- ✅ 使用 GitHub Secrets 安全存储

## 🐛 故障排查

### 问题 1: 部署失败

**检查清单**:
- [ ] GitHub Secrets 是否配置正确
- [ ] SSH 私钥格式是否正确
- [ ] 服务器是否可以 SSH 访问
- [ ] 服务器磁盘空间是否充足

**查看 GitHub Actions 日志**:
进入 Actions > 选择失败的 workflow > 查看详细日志

### 问题 2: 服务无法启动

```bash
# 查看服务状态
systemctl status yak-embedding-service

# 查看详细日志
journalctl -u yak-embedding-service -n 100 --no-pager

# 检查配置文件
cat /root/yaklang-ai-training-materials/apps/embedding/.env

# 手动测试启动
cd /root/yaklang-ai-training-materials
yak scripts/start-yak-embedding-service.yak --port 9099 --totp-secret "your-secret"
```

### 问题 3: 端口冲突

```bash
# 查找占用端口的进程
lsof -i :9099

# 或使用 netstat
netstat -tuln | grep 9099

# 杀死占用端口的进程
kill -9 <PID>
```

### 问题 4: TOTP 认证失败

```bash
# 检查服务器时间
timedatectl status

# 同步时间（TOTP 依赖准确时间）
ntpdate -u pool.ntp.org
# 或
timedatectl set-ntp true
```

## 📝 常用命令

```bash
# ====== 服务管理 ======
systemctl status yak-embedding-service    # 查看状态
systemctl start yak-embedding-service     # 启动服务
systemctl stop yak-embedding-service      # 停止服务
systemctl restart yak-embedding-service   # 重启服务
systemctl enable yak-embedding-service    # 启用开机自启
systemctl disable yak-embedding-service   # 禁用开机自启

# ====== 日志查看 ======
journalctl -u yak-embedding-service -f              # 实时日志
journalctl -u yak-embedding-service -n 100          # 最近100行
journalctl -u yak-embedding-service --since today   # 今天的日志
journalctl -u yak-embedding-service --since "2 hours ago"  # 最近2小时

# ====== 配置管理 ======
vim /root/yaklang-ai-training-materials/apps/embedding/.env  # 编辑配置
cat /root/yaklang-ai-training-materials/apps/embedding/.env  # 查看配置

# ====== 测试服务 ======
curl http://127.0.0.1:9099/health                   # 健康检查
cd /root/yaklang-ai-training-materials && \
  yak scripts/test-yak-embedding-rag-service.yak    # 完整测试
```

## 🔄 更新服务

### 自动更新（推荐）

1. 修改脚本文件
2. 提交并推送到 main 分支
3. GitHub Actions 自动部署
4. 验证服务正常运行

### 手动更新

```bash
# 1. 上传新脚本到服务器
scp scripts/start-yak-embedding-service.yak root@server:/root/yaklang-ai-training-materials/scripts/

# 2. SSH 登录服务器
ssh root@server

# 3. 重新运行部署脚本
cd /root/yaklang-ai-training-materials
bash apps/embedding/deploy-embedding.sh
```

## 📚 相关文档

- [完整部署文档](./README.md)
- [启动脚本说明](../../scripts/start-yak-embedding-service.yak)
- [测试脚本说明](../../scripts/test-yak-embedding-rag-service.yak)

## 💡 最佳实践

1. ✅ **定期备份配置** - 备份 `.env` 文件
2. ✅ **监控服务日志** - 设置日志告警
3. ✅ **定期更新密钥** - 每季度更换 TOTP 密钥
4. ✅ **资源监控** - 监控 CPU、内存使用情况
5. ✅ **定期测试** - 每周运行测试脚本验证服务
6. ✅ **文档更新** - 记录配置变更和问题解决方案

## 🆘 获取帮助

遇到问题？

1. 查看 [故障排查](#-故障排查) 部分
2. 查看 [完整文档](./README.md)
3. 提交 GitHub Issue
4. 联系维护团队

---

**快速开始版本**: 1.0.0  
**最后更新**: 2025-10-29

