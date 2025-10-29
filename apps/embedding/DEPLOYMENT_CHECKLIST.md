# YAK Embedding Service 部署检查清单

## 📋 部署前准备

### GitHub Secrets 配置
- [ ] `EMBEDDING_HOST` - 服务器 SSH 地址（如 `root@192.168.1.100`）
- [ ] `EMBEDDING_HOST_PRIVATE_KEY` - SSH 私钥完整内容
- [ ] `EMBEDDING_PORT` - 服务端口（默认 `9099`）
- [ ] `TOTP_SECRET` - TOTP 认证密钥（至少 32 字符）

### 服务器要求
- [ ] Linux 系统支持 systemd
- [ ] 最低配置：2核4G 内存
- [ ] 推荐配置：4核8G 内存或更高
- [ ] 开放端口：配置的 EMBEDDING_PORT

## 🚀 自动部署流程

### 触发方式
- [ ] 修改相关文件并推送到 main 分支
- [ ] 或在 GitHub Actions 页面手动触发

### 部署步骤（自动执行）
1. [ ] 下载 YAK 引擎
2. [ ] 准备 SSH 密钥
3. [ ] 创建远程目录
4. [ ] 上传启动脚本 (`start-yak-embedding-service.yak`)
5. [ ] 上传 systemd 安装脚本 (`install-yak-scripts-to-systemd.yak`)
6. [ ] 上传部署脚本 (`deploy-embedding.sh`)
7. [ ] 上传证书安装脚本 (`install-certs.sh`)
8. [ ] 上传配置文件 (`.env`)
9. [ ] 执行部署脚本
10. [ ] 验证部署结果

## ✅ 部署验证

### 基础服务检查
```bash
# SSH 登录服务器
ssh root@your-server-ip

# 检查服务状态
systemctl status yak-embedding-service

# 查看服务日志
journalctl -u yak-embedding-service -f

# 测试本地访问
curl http://127.0.0.1:9099/health
```

### 部署状态确认
- [ ] Systemd 服务已安装并运行
- [ ] 服务端口正常监听
- [ ] 日志输出正常，无错误
- [ ] TOTP 认证工作正常

## 🔒 SSL/TLS 证书配置（可选）

### 前置条件
- [ ] 域名 DNS 已解析到服务器 IP
- [ ] 防火墙已开放 80 和 443 端口
- [ ] Embedding 服务已正常运行

### 执行证书安装
```bash
# SSH 登录服务器
ssh root@your-server-ip

# 进入部署目录
cd /root/yaklang-ai-training-materials/apps/embedding

# 运行证书安装脚本
bash install-certs.sh \
  --domain your-embedding-domain.com \
  --port 9099 \
  --email admin@example.com \
  --yes
```

### 证书配置验证
- [ ] Nginx 已安装并运行
- [ ] SSL 证书已成功签发
- [ ] HTTP 访问正常（`http://your-domain.com/health`）
- [ ] HTTPS 访问正常（`https://your-domain.com/health`）
- [ ] 证书自动续期已配置

## 📊 功能对比检查

### 与 Health Checking 服务对比

| 功能特性 | Health Checking | Embedding Service | 状态 |
|---------|----------------|-------------------|------|
| Systemd 自动管理 | ✅ | ✅ | 已配置 |
| TOTP 安全认证 | ✅ | ✅ | 已配置 |
| 服务自动重启 | ✅ | ✅ | 已配置 |
| 开机自启动 | ✅ | ✅ | 已配置 |
| 日志管理 | ✅ | ✅ | 已配置 |
| 健康检查端点 | ✅ | ✅ | 已配置 |
| SSL/TLS 加密 | ✅ | ✅ | **需手动运行脚本** |
| Nginx 反向代理 | ✅ | ✅ | **需手动运行脚本** |
| 证书自动续期 | ✅ | ✅ | **需手动运行脚本** |
| HTTP/HTTPS 双协议 | ✅ | ✅ | **需手动运行脚本** |
| CORS 跨域支持 | ✅ | ✅ | **需手动运行脚本** |
| WebSocket 支持 | ✅ | ✅ | **需手动运行脚本** |

## 🔧 常用管理命令

### 服务管理
```bash
systemctl status yak-embedding-service     # 查看状态
systemctl restart yak-embedding-service    # 重启服务
systemctl stop yak-embedding-service       # 停止服务
systemctl start yak-embedding-service      # 启动服务
```

### 日志查看
```bash
journalctl -u yak-embedding-service -f              # 实时日志
journalctl -u yak-embedding-service -n 100          # 最近 100 行
journalctl -u yak-embedding-service --since today   # 今天的日志
```

### SSL 证书管理（如已配置）
```bash
ssl-manager status    # 查看证书状态
ssl-manager renew     # 手动续期证书
nginx -t              # 测试 Nginx 配置
systemctl reload nginx # 重新加载 Nginx
```

## 🐛 故障排查

### 部署失败
1. [ ] 检查 GitHub Secrets 配置是否正确
2. [ ] 检查 SSH 私钥格式是否正确
3. [ ] 检查服务器是否可 SSH 访问
4. [ ] 查看 GitHub Actions 日志

### 服务无法启动
1. [ ] 查看服务状态：`systemctl status yak-embedding-service`
2. [ ] 查看详细日志：`journalctl -u yak-embedding-service -n 100`
3. [ ] 检查配置文件：`cat /root/yaklang-ai-training-materials/apps/embedding/.env`
4. [ ] 检查端口占用：`lsof -i :9099`

### HTTPS 无法访问（如已配置证书）
1. [ ] 检查 DNS 解析：`nslookup your-domain.com`
2. [ ] 检查防火墙：`ufw status` 或 `firewall-cmd --list-all`
3. [ ] 检查 Nginx 状态：`systemctl status nginx`
4. [ ] 检查证书状态：`ssl-manager status`
5. [ ] 测试 Nginx 配置：`nginx -t`

## 📚 相关文档

- [完整部署文档](./README.md)
- [快速开始指南](./QUICK_START.md)
- [启动脚本](../../scripts/start-yak-embedding-service.yak)
- [测试脚本](../../scripts/test-yak-embedding-rag-service.yak)

---

**更新时间**: 2025-10-29  
**版本**: 1.0.0
