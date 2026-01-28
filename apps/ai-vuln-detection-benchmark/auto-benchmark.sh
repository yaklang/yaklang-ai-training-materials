#!/bin/bash
# =============================================================================
# AI Benchmark Auto Runner
# 功能: 自动检测最新 Yaklang 引擎版本并执行基准测试
# 执行周期: 每 5 分钟检查一次
# =============================================================================

# 不使用 set -e，手动处理错误以便记录详细信息

# ============= 配置部分 =============
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVICE_DIR="/root/yaklang-ai-training-materials/ai-vuln-detection-benchmark-service"
ENGINE_DIR="${SERVICE_DIR}/yak-engine"
CONFIG_FILE="${SERVICE_DIR}/config.json"
LOG_FILE="${SERVICE_DIR}/auto-benchmark.log"
LOCK_FILE="${SERVICE_DIR}/benchmark.lock"

# 工作目录
WORK_DIR="/root/yaklang-ai-training-materials"
APP_PATH="apps/ai-vuln-detection-benchmark"

# 配置文件路径
TEST_CONFIG="${WORK_DIR}/${APP_PATH}/test-config.json"
AI_CONFIG="${WORK_DIR}/${APP_PATH}/ai-config.json"
BENCHMARK_SCRIPT="${WORK_DIR}/${APP_PATH}/ai-model-vuln-detection-benchmark.yak"
BENCHMARK_FRONTEND="${WORK_DIR}/${APP_PATH}/ai-model-vuln-detection-benchmark.html"
BENCHMARK_ENV_FILE="${WORK_DIR}/${APP_PATH}/.env.benchmark"
REPORT_DIR="/root/ai-benchmark-reports-v2"

# 引擎版本信息
VERSION_URL="https://yaklang.oss-accelerate.aliyuncs.com/yak/latest/version.txt"
ENGINE_DOWNLOAD_URL_TEMPLATE="https://yaklang.oss-accelerate.aliyuncs.com/yak/{VERSION}/yak_linux_amd64"

# ============= 日志函数 =============
log_info() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] $*" | tee -a "$LOG_FILE" >&2
}

log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] $*" | tee -a "$LOG_FILE" >&2
}

log_warn() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [WARN] $*" | tee -a "$LOG_FILE" >&2
}

# ============= 初始化 =============
init_service() {
    log_info "Initializing service directories..."
    
    # 创建必要的目录
    mkdir -p "$SERVICE_DIR"
    mkdir -p "$ENGINE_DIR"
    mkdir -p "$REPORT_DIR"
    
    # 如果配置文件不存在，创建初始配置
    if [ ! -f "$CONFIG_FILE" ]; then
        log_info "Creating initial config file..."
        cat > "$CONFIG_FILE" <<EOF
# AI Benchmark Auto Runner Configuration
# Last updated: $(date '+%Y-%m-%d %H:%M:%S')

current_version=
last_run_time=
last_check_time=
engine_path=
total_runs=0
last_run_success=false
last_run_error=
EOF
    fi
    
    log_info "Service directories initialized"
}

# ============= 配置文件操作 =============
read_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo ""
        return
    fi
    
    local key="$1"
    # 读取 Key=Value 格式的配置
    local value=$(grep "^${key}=" "$CONFIG_FILE" 2>/dev/null | cut -d'=' -f2- || echo "")
    echo "$value"
}

update_config() {
    local key="$1"
    local value="$2"
    
    if [ ! -f "$CONFIG_FILE" ]; then
        init_service
    fi
    
    # 更新 Key=Value 格式的配置
    # 使用 grep + 重写文件的方式，避免 sed 处理特殊字符的问题
    local tmp_file="${CONFIG_FILE}.tmp"
    
    if grep -q "^${key}=" "$CONFIG_FILE" 2>/dev/null; then
        # 更新现有键：先写入其他行，再写入新值
        grep -v "^${key}=" "$CONFIG_FILE" > "$tmp_file"
        echo "${key}=${value}" >> "$tmp_file"
        mv "$tmp_file" "$CONFIG_FILE"
    else
        # 添加新键（追加到文件末尾）
        echo "${key}=${value}" >> "$CONFIG_FILE"
    fi
}

# 数字和布尔值也使用相同的函数
update_config_number() {
    update_config "$1" "$2"
}

update_config_bool() {
    update_config "$1" "$2"
}

# ============= 版本检查 =============
get_latest_version() {
    log_info "Fetching latest engine version from $VERSION_URL..."
    
    local version=$(curl -s --connect-timeout 10 --max-time 30 --retry 3 --retry-delay 5 "$VERSION_URL" | tr -d '[:space:]')
    
    if [ -z "$version" ]; then
        log_error "Failed to fetch latest version from OSS"
        return 1
    fi
    
    log_info "Latest version: $version"
    echo "$version"
}

# ============= 引擎下载 =============
download_engine() {
    local version="$1"
    # 直接构造 URL，避免使用模板替换
    local engine_url="https://yaklang.oss-accelerate.aliyuncs.com/yak/${version}/yak_linux_amd64"
    local engine_path="${ENGINE_DIR}/yak-${version}"
    
    log_info "Downloading engine version $version..."
    log_info "URL: $engine_url"
    log_info "Target: $engine_path"
    
    # 如果文件已存在且可执行，跳过下载
    if [ -f "$engine_path" ] && [ -x "$engine_path" ]; then
        log_info "Engine already exists and is executable: $engine_path"
        echo "$engine_path"
        return 0
    fi
    
    # 下载引擎
    local tmp_file="${engine_path}.tmp"
    if ! curl -L --progress-bar --connect-timeout 30 --max-time 300 \
         -o "$tmp_file" "$engine_url"; then
        log_error "Failed to download engine"
        rm -f "$tmp_file"
        return 1`
    fi
    
    # 验证下载的文件
    if [ ! -f "$tmp_file" ] || [ ! -s "$tmp_file" ]; then
        log_error "Downloaded file is empty or missing"
        rm -f "$tmp_file"
        return 1
    fi
    
    # 移动到目标位置
    mv "$tmp_file" "$engine_path"
    
    # 添加执行权限
    chmod +x "$engine_path"
    
    # 验证文件类型
    if ! file "$engine_path" | grep -q "executable"; then
        log_error "Downloaded file is not a valid executable"
        rm -f "$engine_path"
        return 1
    fi
    
    log_info "Engine downloaded successfully: $engine_path"
    echo "$engine_path"
}

# ============= 执行基准测试 =============
run_benchmark() {
    local engine_path="$1"
    local version="$2"
    
    log_info "=========================================="
    log_info "Starting benchmark test with engine $version"
    log_info "Engine: $engine_path"
    log_info "Test Config: $TEST_CONFIG"
    log_info "AI Config: $AI_CONFIG"
    log_info "Report Dir: $REPORT_DIR"
    log_info "=========================================="
    
    # 检查必要文件
    if [ ! -f "$TEST_CONFIG" ]; then
        log_error "Test config not found: $TEST_CONFIG"
        return 1
    fi
    
    if [ ! -f "$AI_CONFIG" ]; then
        log_error "AI config not found: $AI_CONFIG"
        return 1
    fi
    
    if [ ! -f "$BENCHMARK_SCRIPT" ]; then
        log_error "Benchmark script not found: $BENCHMARK_SCRIPT"
        return 1
    fi
    
    # 从环境变量文件加载配置
    local api_key=""
    if [ -f "$BENCHMARK_ENV_FILE" ]; then
        log_info "Loading environment from: $BENCHMARK_ENV_FILE"
        # 读取 AI_BENCHMARK_API_KEY
        api_key=$(grep "^AI_BENCHMARK_API_KEY=" "$BENCHMARK_ENV_FILE" 2>/dev/null | cut -d'=' -f2- || echo "")
        if [ -n "$api_key" ]; then
            log_info "API Key loaded from env file: [REDACTED]"
        else
            log_warn "AI_BENCHMARK_API_KEY not found in env file"
        fi
    else
        log_warn "Environment file not found: $BENCHMARK_ENV_FILE"
    fi
    
    # 执行基准测试
    local start_time=$(date '+%Y-%m-%d %H:%M:%S')
    log_info "Test started at: $start_time"
    
    # 切换到工作目录
    cd "$WORK_DIR"
    
    # 创建临时日志文件捕获详细错误
    local test_log="${LOG_FILE}.test.tmp"
    
    # 构建 --var 参数
    local var_args=""
    if [ -n "$api_key" ]; then
        var_args="--var aibalance-ai-benchmark-api-key=${api_key}"
        log_info "Variable parameter added: aibalance-ai-benchmark-api-key=[REDACTED]"
    fi
    
    # 执行测试（捕获输出到临时日志）
    log_info "Executing benchmark test..."
    "$engine_path" "$BENCHMARK_SCRIPT" \
        --config "$TEST_CONFIG" \
        --ai-config "$AI_CONFIG" \
        --output-dir "$REPORT_DIR" \
        --yaklang-engine-version "$version" \
        --frontend "$BENCHMARK_FRONTEND" \
        $var_args \
        > "$test_log" 2>&1
    
    local exit_code=$?
    
    # 将测试输出追加到主日志
    cat "$test_log" >> "$LOG_FILE"
    
    if [ $exit_code -eq 0 ]; then
        local end_time=$(date '+%Y-%m-%d %H:%M:%S')
        log_info "Test completed successfully at: $end_time"
        
        # 更新配置
        update_config "last_run_time" "$start_time"
        update_config_bool "last_run_success" "true"
        update_config "last_run_error" ""
        
        local total_runs=$(read_config "total_runs")
        if [ -z "$total_runs" ]; then
            total_runs=0
        fi
        total_runs=$((total_runs + 1))
        update_config_number "total_runs" "$total_runs"
        
        rm -f "$test_log"
        return 0
    else
        local end_time=$(date '+%Y-%m-%d %H:%M:%S')
        log_error "Test failed at: $end_time with exit code: $exit_code"
        
        # 提取最后几行错误信息
        local error_msg=$(tail -n 5 "$test_log" | tr '\n' ' ' | head -c 200)
        log_error "Error details: $error_msg"
        
        # 更新配置
        update_config "last_run_time" "$start_time"
        update_config_bool "last_run_success" "false"
        update_config "last_run_error" "Exit code: $exit_code. Check log: $LOG_FILE"
        
        rm -f "$test_log"
        return 1
    fi
}

# ============= 清理旧引擎 =============
cleanup_old_engines() {
    log_info "Cleaning up old engine versions..."
    
    # 保留最新的 3 个版本
    local keep_count=3
    local engines=($(ls -t "$ENGINE_DIR"/yak-* 2>/dev/null || true))
    local engine_count=${#engines[@]}
    
    if [ "$engine_count" -le "$keep_count" ]; then
        log_info "No old engines to clean up (total: $engine_count)"
        return
    fi
    
    log_info "Found $engine_count engine versions, keeping latest $keep_count"
    
    for ((i=$keep_count; i<$engine_count; i++)); do
        local engine_to_remove="${engines[$i]}"
        log_info "Removing old engine: $engine_to_remove"
        rm -f "$engine_to_remove"
    done
}

# ============= 主逻辑 =============
main() {
    # 首先确保服务目录存在（用于日志）
    mkdir -p "$SERVICE_DIR"
    mkdir -p "$ENGINE_DIR"
    mkdir -p "$REPORT_DIR"
    
    log_info "=========================================="
    log_info "AI Benchmark Auto Runner Started"
    log_info "=========================================="
    
    # 检查锁文件，避免重复执行
    if [ -f "$LOCK_FILE" ]; then
        local lock_pid=$(cat "$LOCK_FILE")
        if kill -0 "$lock_pid" 2>/dev/null; then
            log_warn "Another instance is running (PID: $lock_pid), exiting"
            exit 0
        else
            log_warn "Stale lock file found, removing"
            rm -f "$LOCK_FILE"
        fi
    fi
    
    # 创建锁文件
    echo $$ > "$LOCK_FILE"
    
    # 确保退出时删除锁文件
    trap "rm -f '$LOCK_FILE'" EXIT
    
    # 初始化服务
    init_service
    
    # 更新检查时间
    update_config "last_check_time" "$(date '+%Y-%m-%d %H:%M:%S')"
    
    # 获取当前配置的版本
    local current_version=$(read_config "current_version")
    log_info "Current engine version in config: ${current_version:-'(empty)'}"
    
    # 获取最新版本
    local latest_version=$(get_latest_version)
    local use_existing=false
    
    if [ -z "$latest_version" ]; then
        log_warn "Failed to get latest version"
        
        if [ -n "$current_version" ] && [ -f "$(read_config "engine_path")" ]; then
            log_info "Fallback to existing version: $current_version"
            latest_version="$current_version"
            use_existing=true
        else
            log_error "No existing version available, cannot proceed"
            update_config "last_run_error" "Failed to fetch latest version and no local version found"
            exit 0
        fi
    fi
    
    # 判断是否需要更新
    local engine_path=""
    
    if [ "$use_existing" = "true" ]; then
        log_info "Using existing version due to version check failure"
        need_update=false
        engine_path=$(read_config "engine_path")
    elif [ -z "$current_version" ]; then
        log_info "No version configured, will download latest version"
        need_update=true
    elif [ "$current_version" != "$latest_version" ]; then
        log_info "Version mismatch: current=$current_version, latest=$latest_version"
        log_info "Will download and test new version"
        need_update=true
    else
        log_info "Version is up to date: $current_version"
        log_info "Checking if engine file exists..."
        engine_path=$(read_config "engine_path")
        if [ ! -f "$engine_path" ]; then
             log_warn "Engine file missing, forcing redownload"
             need_update=true
        else
             log_info "No update needed, exiting"
             need_update=false
        fi
    fi
    
    # 如果不需要更新，退出
    if [ "$need_update" = "false" ]; then
        if [ -n "$engine_path" ] && [ -x "$engine_path" ]; then
             local last_run_success=$(read_config "last_run_success")
             if [ "$last_run_success" != "true" ]; then
                 log_info "Last run failed, forcing rerun with current version"
                 engine_path=$(read_config "engine_path")
                 # 继续执行下载（检查）和测试逻辑
             else
                 log_info "=========================================="
                 log_info "No update required and last run was successful, exiting"
                 log_info "=========================================="
                 exit 0
             fi
        else
             log_error "Engine path invalid or missing: $engine_path"
             need_update=true
        fi
    fi
    
    if [ "$need_update" = "true" ]; then
        # 下载引擎
        engine_path=$(download_engine "$latest_version")
        if [ $? -ne 0 ] || [ -z "$engine_path" ]; then
            log_error "Failed to download engine, will retry on next run"
            update_config "last_run_error" "Failed to download engine version $latest_version"
            exit 0
        fi
        
        # 更新配置中的版本和引擎路径
        update_config "current_version" "$latest_version"
        update_config "engine_path" "$engine_path"
    fi
    
    # 执行基准测试
    if run_benchmark "$engine_path" "$latest_version"; then
        log_info "Benchmark completed successfully"
        
        # 清理旧引擎
        cleanup_old_engines
        
        log_info "=========================================="
        log_info "AI Benchmark Auto Runner Completed Successfully"
        log_info "=========================================="
        exit 0
    else
        log_error "Benchmark failed, but will retry on next run"
        log_error "Check log file for details: $LOG_FILE"
        log_info "=========================================="
        log_info "AI Benchmark Auto Runner Completed with Errors"
        log_info "=========================================="
        # 不要 exit 1，让 systemd 认为服务正常结束
        # 下次定时器触发时会重试
        exit 0
    fi
}

# 执行主函数
main "$@"

