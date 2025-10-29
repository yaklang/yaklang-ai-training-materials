#!/bin/bash
# =============================================================================
# YAK Embedding Service Deployment Script
# 功能: 部署和管理 YAK Embedding 服务
# 用途: 自动化安装、配置、启动 embedding 服务
# =============================================================================

set -e  # 遇到错误立即退出

echo "============================================"
echo "YAK Embedding Service Deployment"
echo "============================================"
echo ""

# =============================================================================
# 配置变量
# =============================================================================

WORK_DIR="/root/yaklang-ai-training-materials"
SCRIPTS_DIR="${WORK_DIR}/scripts"
CONFIG_DIR="${WORK_DIR}/apps/embedding"
SERVICE_NAME="yak-embedding-service"
START_SCRIPT="${SCRIPTS_DIR}/start-yak-embedding-service.yak"
INSTALL_SCRIPT="${SCRIPTS_DIR}/install-yak-scripts-to-systemd.yak"
CONFIG_FILE="${CONFIG_DIR}/.env"

# =============================================================================
# 检查必要文件
# =============================================================================

echo "=== Checking required files ==="

if [ ! -f "$START_SCRIPT" ]; then
    echo "ERROR: Start script not found: $START_SCRIPT"
    exit 1
fi

if [ ! -f "$INSTALL_SCRIPT" ]; then
    echo "ERROR: Install script not found: $INSTALL_SCRIPT"
    exit 1
fi

if [ ! -f "$CONFIG_FILE" ]; then
    echo "ERROR: Configuration file not found: $CONFIG_FILE"
    exit 1
fi

echo "✓ All required files found"
echo ""

# =============================================================================
# 读取配置
# =============================================================================

echo "=== Loading configuration ==="

source "$CONFIG_FILE"

if [ -z "$EMBEDDING_PORT" ] || [ -z "$TOTP_SECRET" ]; then
    echo "ERROR: Configuration incomplete"
    echo "Required: EMBEDDING_PORT, TOTP_SECRET"
    exit 1
fi

echo "Configuration loaded:"
echo "  Port: $EMBEDDING_PORT"
echo "  TOTP Secret: [REDACTED]"
echo ""

# =============================================================================
# 检查并下载 YAK 引擎
# =============================================================================

echo "=== Checking YAK engine ==="

YAK_PATH="/usr/local/bin/yak"
YAK_VERSION="1.4.4-alpha1027"

if [ ! -f "$YAK_PATH" ]; then
    echo "YAK engine not found, downloading..."
    
    YAK_URL="https://yaklang.oss-accelerate.aliyuncs.com/yak/${YAK_VERSION}/yak_linux_amd64"
    
    wget -q --show-progress "$YAK_URL" -O /tmp/yak || {
        echo "ERROR: Failed to download YAK engine"
        exit 1
    }
    
    chmod +x /tmp/yak
    mv /tmp/yak "$YAK_PATH"
    
    echo "✓ YAK engine installed: $YAK_PATH"
else
    echo "✓ YAK engine found: $YAK_PATH"
fi

# 验证 YAK 可执行
if ! "$YAK_PATH" version >/dev/null 2>&1; then
    echo "Note: yak version command may not be available, but binary exists"
fi

echo ""

# =============================================================================
# 停止现有服务（如果存在）
# =============================================================================

echo "=== Stopping existing service ==="

if systemctl is-active --quiet "$SERVICE_NAME"; then
    echo "Stopping $SERVICE_NAME..."
    systemctl stop "$SERVICE_NAME"
    echo "✓ Service stopped"
else
    echo "Service not running"
fi

echo ""

# =============================================================================
# 安装/更新 systemd 服务
# =============================================================================

echo "=== Installing systemd service ==="

# 构建脚本参数
SCRIPT_ARGS="--port ${EMBEDDING_PORT} --totp-secret \"${TOTP_SECRET}\" --concurrent 5"

echo "Service configuration:"
echo "  Name: $SERVICE_NAME"
echo "  Script: $START_SCRIPT"
echo "  Args: --port ${EMBEDDING_PORT} --totp-secret [REDACTED] --concurrent 5"
echo ""

# 安装服务
"$YAK_PATH" "$INSTALL_SCRIPT" \
    --service-name "$SERVICE_NAME" \
    --script-path "$START_SCRIPT" \
    --script-args "$SCRIPT_ARGS" \
    --user root \
    --group root \
    --restart always \
    --type simple

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to install systemd service"
    exit 1
fi

echo "✓ Service installed successfully"
echo ""

# =============================================================================
# 重新加载 systemd 并启动服务
# =============================================================================

echo "=== Starting service ==="

# 重新加载 systemd 配置
systemctl daemon-reload

# 启用服务（开机自启动）
systemctl enable "$SERVICE_NAME"

# 启动服务
systemctl start "$SERVICE_NAME"

# 等待服务启动
sleep 3

# 检查服务状态
if systemctl is-active --quiet "$SERVICE_NAME"; then
    echo "✓ Service started successfully"
    echo ""
    
    # 显示服务状态
    echo "=== Service Status ==="
    systemctl status "$SERVICE_NAME" --no-pager || true
    echo ""
else
    echo "ERROR: Service failed to start"
    echo ""
    echo "=== Service Status ==="
    systemctl status "$SERVICE_NAME" --no-pager || true
    echo ""
    echo "=== Recent Logs ==="
    journalctl -u "$SERVICE_NAME" -n 50 --no-pager || true
    exit 1
fi

# =============================================================================
# 验证服务端口
# =============================================================================

echo "=== Verifying service ==="

# 等待端口监听
echo "Waiting for port $EMBEDDING_PORT..."
for i in {1..10}; do
    if netstat -tuln 2>/dev/null | grep -q ":${EMBEDDING_PORT} " || \
       ss -tuln 2>/dev/null | grep -q ":${EMBEDDING_PORT} "; then
        echo "✓ Service is listening on port $EMBEDDING_PORT"
        break
    fi
    
    if [ $i -eq 10 ]; then
        echo "WARNING: Port $EMBEDDING_PORT not detected after 10 seconds"
        echo "Service may still be starting..."
    fi
    
    sleep 1
done

echo ""

# =============================================================================
# 部署完成
# =============================================================================

echo "============================================"
echo "✅ Deployment Completed Successfully"
echo "============================================"
echo ""
echo "Service Information:"
echo "  Name: $SERVICE_NAME"
echo "  Status: $(systemctl is-active $SERVICE_NAME)"
echo "  Port: $EMBEDDING_PORT"
echo "  Auto-start: Enabled"
echo ""
echo "Useful Commands:"
echo "  Status:  systemctl status $SERVICE_NAME"
echo "  Logs:    journalctl -u $SERVICE_NAME -f"
echo "  Restart: systemctl restart $SERVICE_NAME"
echo "  Stop:    systemctl stop $SERVICE_NAME"
echo ""
echo "Configuration:"
echo "  Config file: $CONFIG_FILE"
echo "  Start script: $START_SCRIPT"
echo ""

