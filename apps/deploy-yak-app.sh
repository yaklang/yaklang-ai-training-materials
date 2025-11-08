#!/bin/bash
# =============================================================================
# YAK Application Universal Deployment Script
# 功能: 完全通用的 YAK 应用部署和管理脚本
# 用途: 通过参数控制部署任何 YAK 应用
# =============================================================================

set -e  # 遇到错误立即退出

# =============================================================================
# 使用说明
# =============================================================================

function show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

完全通用的 YAK 应用部署脚本

REQUIRED OPTIONS:
    --service-name <name>     systemd 服务名称
    --main-script <path>      主脚本路径（绝对路径或相对于工作目录）

OPTIONAL OPTIONS:
    --config-file <path>      配置文件路径（绝对路径或相对于工作目录）
                             如果提供，会被 source 加载环境变量
    
    --app-name <name>         应用显示名称（默认: 使用服务名称）
    
    --work-dir <path>         工作目录（默认: /root/yaklang-ai-training-materials）
    
    --script-args <args>      传递给主脚本的参数
                             支持使用环境变量引用，如: --script-args "--port \$APP_PORT"
    
    --install-script <path>   systemd 安装脚本路径
                             （默认: {work-dir}/scripts/install-yak-scripts-to-systemd.yak）
    
    --yak-path <path>         YAK 引擎路径（默认: /usr/local/bin/yak）
    
    --yak-version <version>   YAK 引擎版本（默认: 1.4.4-beta10
    
    --install-yak             如果 YAK 不存在，自动下载安装
    
    --user <user>             systemd 服务运行用户（默认: root）
    
    --group <group>           systemd 服务运行组（默认: root）
    
    --restart <policy>        systemd 重启策略（默认: always）
    
    --type <type>             systemd 服务类型（默认: simple）
    
    --verify-port <port>      验证服务是否监听指定端口
    
    --skip-verification       跳过端口验证步骤
    
    -h, --help               显示此帮助信息

EXAMPLES:
    # 部署 embedding 服务
    $0 --service-name yak-embedding-service \\
       --main-script /root/yaklang-ai-training-materials/scripts/start-yak-embedding-service.yak \\
       --config-file /root/yaklang-ai-training-materials/apps/embedding/.env \\
       --app-name "YAK Embedding Service"
    
    # 部署 code-helper 应用（使用配置文件）
    $0 --service-name yak-code-helper \\
       --main-script apps/code-helper/code-helper.yak \\
       --config-file apps/code-helper/.env \\
       --script-args "--port \\\$APP_PORT" \\
       --verify-port 8080
    
    # 部署应用（不使用配置文件，直接指定参数）
    $0 --service-name yak-aireact-web \\
       --main-script apps/aireact-web/aireact-web.yak \\
       --script-args "--port 9092" \\
       --verify-port 9092
    
    # 使用环境变量引用（配置文件中的变量会被展开）
    $0 --service-name my-service \\
       --main-script apps/my-app/my-app.yak \\
       --config-file apps/my-app/.env \\
       --script-args "--port \\\$APP_PORT --timeout \\\$TIMEOUT"
    
    # 自动安装 YAK 并部署
    $0 --service-name yak-app \\
       --main-script apps/app/app.yak \\
       --config-file apps/app/.env \\
       --install-yak

NOTES:
    - 如果路径不是绝对路径，会相对于 work-dir 进行解析
    - 配置文件是可选的，如果提供则会被 source 加载环境变量
    - script-args 中可以使用 \$VAR 语法引用环境变量
    - 环境变量会在加载配置文件后自动展开，例如 "\$APP_PORT" 会被替换为实际值
    - 如果不使用配置文件，可以在 script-args 中直接指定具体的值

EOF
}

# =============================================================================
# 默认配置
# =============================================================================

SERVICE_NAME=""
MAIN_SCRIPT=""
CONFIG_FILE=""
APP_NAME=""
WORK_DIR="/root/yaklang-ai-training-materials"
SCRIPT_ARGS=""
INSTALL_SCRIPT=""
YAK_PATH="/usr/local/bin/yak"
YAK_VERSION="1.4.4-beta10"
INSTALL_YAK=false
SERVICE_USER="root"
SERVICE_GROUP="root"
RESTART_POLICY="always"
SERVICE_TYPE="simple"
VERIFY_PORT=""
SKIP_VERIFICATION=false

# =============================================================================
# 解析命令行参数
# =============================================================================

while [[ $# -gt 0 ]]; do
    case $1 in
        --service-name)
            SERVICE_NAME="$2"
            shift 2
            ;;
        --main-script)
            MAIN_SCRIPT="$2"
            shift 2
            ;;
        --config-file)
            CONFIG_FILE="$2"
            shift 2
            ;;
        --app-name)
            APP_NAME="$2"
            shift 2
            ;;
        --work-dir)
            WORK_DIR="$2"
            shift 2
            ;;
        --script-args)
            SCRIPT_ARGS="$2"
            shift 2
            ;;
        --install-script)
            INSTALL_SCRIPT="$2"
            shift 2
            ;;
        --yak-path)
            YAK_PATH="$2"
            shift 2
            ;;
        --yak-version)
            YAK_VERSION="$2"
            shift 2
            ;;
        --install-yak)
            INSTALL_YAK=true
            shift
            ;;
        --user)
            SERVICE_USER="$2"
            shift 2
            ;;
        --group)
            SERVICE_GROUP="$2"
            shift 2
            ;;
        --restart)
            RESTART_POLICY="$2"
            shift 2
            ;;
        --type)
            SERVICE_TYPE="$2"
            shift 2
            ;;
        --verify-port)
            VERIFY_PORT="$2"
            shift 2
            ;;
        --skip-verification)
            SKIP_VERIFICATION=true
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            echo "ERROR: Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# =============================================================================
# 验证必需参数
# =============================================================================

if [ -z "$SERVICE_NAME" ]; then
    echo "ERROR: --service-name is required"
    echo "Use --help for usage information"
    exit 1
fi

if [ -z "$MAIN_SCRIPT" ]; then
    echo "ERROR: --main-script is required"
    echo "Use --help for usage information"
    exit 1
fi

# 设置默认值
if [ -z "$APP_NAME" ]; then
    APP_NAME="$SERVICE_NAME"
fi

if [ -z "$INSTALL_SCRIPT" ]; then
    INSTALL_SCRIPT="${WORK_DIR}/scripts/install-yak-scripts-to-systemd.yak"
fi

# =============================================================================
# 解析路径（转换相对路径为绝对路径）
# =============================================================================

function resolve_path() {
    local path="$1"
    if [[ "$path" = /* ]]; then
        # 已经是绝对路径
        echo "$path"
    else
        # 相对路径，相对于工作目录
        echo "${WORK_DIR}/${path}"
    fi
}

MAIN_SCRIPT=$(resolve_path "$MAIN_SCRIPT")
INSTALL_SCRIPT=$(resolve_path "$INSTALL_SCRIPT")

# 只有指定了配置文件才解析路径
if [ -n "$CONFIG_FILE" ]; then
    CONFIG_FILE=$(resolve_path "$CONFIG_FILE")
fi

# =============================================================================
# 显示部署信息
# =============================================================================

echo "============================================"
echo "YAK Application Deployment"
echo "============================================"
echo ""
echo "Application: $APP_NAME"
echo "Service Name: $SERVICE_NAME"
echo "Work Directory: $WORK_DIR"
echo "Main Script: $MAIN_SCRIPT"

if [ -n "$CONFIG_FILE" ]; then
    echo "Config File: $CONFIG_FILE"
else
    echo "Config File: (none)"
fi

echo "Install Script: $INSTALL_SCRIPT"
echo "YAK Path: $YAK_PATH"
echo "YAK Version: $YAK_VERSION"
echo ""

# =============================================================================
# 检查必要文件
# =============================================================================

echo "=== Checking required files ==="

if [ ! -f "$MAIN_SCRIPT" ]; then
    echo "ERROR: Main script not found: $MAIN_SCRIPT"
    exit 1
fi

if [ ! -f "$INSTALL_SCRIPT" ]; then
    echo "ERROR: Install script not found: $INSTALL_SCRIPT"
    exit 1
fi

# 只有指定了配置文件才检查
if [ -n "$CONFIG_FILE" ] && [ ! -f "$CONFIG_FILE" ]; then
    echo "ERROR: Configuration file not found: $CONFIG_FILE"
    exit 1
fi

echo "✓ All required files found"
echo ""

# =============================================================================
# 读取配置
# =============================================================================

if [ -n "$CONFIG_FILE" ]; then
    echo "=== Loading configuration ==="
    
    source "$CONFIG_FILE"
    
    echo "✓ Configuration file loaded"
else
    echo "=== No configuration file ==="
    echo "Skipping configuration loading"
fi

# 如果指定了脚本参数，展开其中的环境变量
if [ -n "$SCRIPT_ARGS" ]; then
    # 使用 eval 展开环境变量
    SCRIPT_ARGS=$(eval echo "$SCRIPT_ARGS")
    echo "✓ Script arguments expanded"
    
    # 显示脚本参数（隐藏敏感信息）
    SAFE_ARGS=$(echo "$SCRIPT_ARGS" | sed 's/--totp-secret "[^"]*"/--totp-secret [REDACTED]/g')
    echo "  Script Args: $SAFE_ARGS"
fi

echo ""

# =============================================================================
# 检查并安装 YAK 引擎
# =============================================================================

echo "=== Checking YAK engine ==="

if [ ! -f "$YAK_PATH" ]; then
    if [ "$INSTALL_YAK" = true ]; then
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
        echo "ERROR: yak command not found at $YAK_PATH"
        echo "Use --install-yak to automatically download and install"
        exit 1
    fi
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

echo "Service configuration:"
echo "  Name: $SERVICE_NAME"
echo "  Script: $MAIN_SCRIPT"
echo "  User: $SERVICE_USER"
echo "  Group: $SERVICE_GROUP"
echo "  Restart Policy: $RESTART_POLICY"
echo "  Type: $SERVICE_TYPE"

if [ -n "$SCRIPT_ARGS" ]; then
    # 隐藏敏感参数
    SAFE_ARGS=$(echo "$SCRIPT_ARGS" | sed 's/--totp-secret "[^"]*"/--totp-secret [REDACTED]/g')
    echo "  Args: $SAFE_ARGS"
else
    echo "  Args: (none)"
fi

echo ""

# 安装服务
"$YAK_PATH" "$INSTALL_SCRIPT" \
    --service-name "$SERVICE_NAME" \
    --script-path "$MAIN_SCRIPT" \
    --script-args "$SCRIPT_ARGS" \
    --user "$SERVICE_USER" \
    --group "$SERVICE_GROUP" \
    --restart "$RESTART_POLICY" \
    --type "$SERVICE_TYPE"

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
# 验证服务端口（可选）
# =============================================================================

if [ "$SKIP_VERIFICATION" = false ] && [ -n "$VERIFY_PORT" ]; then
    echo "=== Verifying service ==="
    
    # 等待端口监听
    echo "Waiting for port $VERIFY_PORT..."
    for i in {1..10}; do
        if netstat -tuln 2>/dev/null | grep -q ":${VERIFY_PORT} " || \
           ss -tuln 2>/dev/null | grep -q ":${VERIFY_PORT} "; then
            echo "✓ Service is listening on port $VERIFY_PORT"
            break
        fi
        
        if [ $i -eq 10 ]; then
            echo "WARNING: Port $VERIFY_PORT not detected after 10 seconds"
            echo "Service may still be starting..."
        fi
        
        sleep 1
    done
    
    echo ""
elif [ "$SKIP_VERIFICATION" = false ] && [ -z "$VERIFY_PORT" ]; then
    echo "=== Skipping port verification ==="
    echo "No port specified for verification (use --verify-port)"
    echo ""
fi

# =============================================================================
# 部署完成
# =============================================================================

echo "============================================"
echo "✅ Deployment Completed Successfully"
echo "============================================"
echo ""
echo "Application Information:"
echo "  Name: $APP_NAME"
echo "  Service: $SERVICE_NAME"
echo "  Status: $(systemctl is-active $SERVICE_NAME)"

if [ -n "$VERIFY_PORT" ]; then
    echo "  Port: $VERIFY_PORT"
elif [ -n "$APP_PORT" ]; then
    echo "  Port: $APP_PORT"
elif [ -n "$EMBEDDING_PORT" ]; then
    echo "  Port: $EMBEDDING_PORT"
fi

echo "  Auto-start: Enabled"
echo "  User: $SERVICE_USER"
echo "  Group: $SERVICE_GROUP"
echo ""
echo "Useful Commands:"
echo "  Status:  systemctl status $SERVICE_NAME"
echo "  Logs:    journalctl -u $SERVICE_NAME -f"
echo "  Restart: systemctl restart $SERVICE_NAME"
echo "  Stop:    systemctl stop $SERVICE_NAME"
echo ""
echo "Configuration:"
if [ -n "$CONFIG_FILE" ]; then
    echo "  Config file: $CONFIG_FILE"
else
    echo "  Config file: (none)"
fi
echo "  Main script: $MAIN_SCRIPT"
echo "  Install script: $INSTALL_SCRIPT"
echo ""

