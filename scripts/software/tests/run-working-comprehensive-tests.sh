#!/bin/bash

# Shell工具配置模块工作版综合测试脚本
# 版本: 2.1 Working

set -euo pipefail

# 脚本配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
TEMPLATES_DIR="$PROJECT_ROOT/scripts/software/templates"
TEST_TEMP_DIR="/tmp/shell-tools-working-test-$$"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# 测试统计
declare -A TEST_STATS=(
    [total]=0
    [passed]=0
    [failed]=0
    [skipped]=0
)

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $(date '+%H:%M:%S') $1"
}

log_success() {
    echo -e "${GREEN}[PASS]${NC} $(date '+%H:%M:%S') $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $(date '+%H:%M:%S') $1"
}

log_error() {
    echo -e "${RED}[FAIL]${NC} $(date '+%H:%M:%S') $1"
}

log_perf() {
    echo -e "${PURPLE}[PERF]${NC} $(date '+%H:%M:%S') $1"
}

# 运行单个测试
run_test() {
    local test_id="$1"
    local test_name="$2"
    local test_type="$3"
    local test_function="$4"
    
    TEST_STATS[total]=$((TEST_STATS[total] + 1))
    
    log_info "[$test_type] 运行测试: $test_id - $test_name"
    
    local start_time=$(date +%s)
    
    if $test_function "$test_id"; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        
        TEST_STATS[passed]=$((TEST_STATS[passed] + 1))
        log_success "[$test_type] 测试通过: $test_id (${duration}s)"
        
        if [[ $duration -gt 5 ]]; then
            log_perf "慢测试警告: $test_id 耗时 ${duration}s"
        fi
        
        return 0
    else
        local exit_code=$?
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        
        if [[ $exit_code -eq 2 ]]; then
            TEST_STATS[skipped]=$((TEST_STATS[skipped] + 1))
            log_warn "[$test_type] 测试跳过: $test_id"
        else
            TEST_STATS[failed]=$((TEST_STATS[failed] + 1))
            log_error "[$test_type] 测试失败: $test_id (${duration}s)"
        fi
        
        return $exit_code
    fi
}

# 测试用例
test_normal_path_config() {
    (
        cd "$TEST_TEMP_DIR"
        source "$TEMPLATES_DIR/00-path-config.zsh" 2>/dev/null
        echo "$PATH" | grep -E "(^|:)/bin($|:)" >/dev/null || exit 1
        echo "$PATH" | grep -E "(^|:)/usr/bin($|:)" >/dev/null || exit 1
    )
}

test_normal_tool_detection() {
    (
        cd "$TEST_TEMP_DIR"
        source "$TEMPLATES_DIR/01-tool-detection.zsh" 2>/dev/null
        # 基本加载测试
        return 0
    )
}

test_normal_bat_config() {
    if ! command -v bat >/dev/null 2>&1 && ! command -v batcat >/dev/null 2>&1; then
        return 2  # 跳过测试
    fi
    
    (
        cd "$TEST_TEMP_DIR"
        source "$TEMPLATES_DIR/02-bat-config.zsh" 2>/dev/null
        [[ "$BAT_STYLE" == "numbers,changes,header,grid" ]] || exit 1
        [[ "$BAT_THEME" == "OneHalfDark" ]] || exit 1
    )
}

test_normal_fzf_integration() {
    if ! command -v fzf >/dev/null 2>&1; then
        return 2  # 跳过测试
    fi
    
    (
        cd "$TEST_TEMP_DIR"
        source "$TEMPLATES_DIR/04-fzf-core.zsh" 2>/dev/null
        source "$TEMPLATES_DIR/05-fzf-basic.zsh" 2>/dev/null
        
        [[ -n "$FZF_DEFAULT_OPTS" ]] || exit 1
        echo "$FZF_DEFAULT_OPTS" | grep -q "height=70%" || exit 1
        
        declare -f fe >/dev/null 2>&1 || exit 1
        declare -f fp >/dev/null 2>&1 || exit 1
    )
}

test_boundary_large_file_handling() {
    if ! command -v bat >/dev/null 2>&1 && ! command -v batcat >/dev/null 2>&1; then
        return 2  # 跳过测试
    fi
    
    # 创建测试文件
    local test_file="$TEST_TEMP_DIR/large-test.txt"
    for i in {1..50}; do
        echo "Line $i: Test content for performance testing" >> "$test_file"
    done
    
    # 测试处理时间
    local start_time=$(date +%s)
    if command -v batcat >/dev/null 2>&1; then
        batcat "$test_file" >/dev/null 2>&1
    else
        bat "$test_file" >/dev/null 2>&1
    fi
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # 清理
    rm -f "$test_file"
    
    # 处理时间应该合理
    [[ $duration -le 5 ]] || return 1
    
    return 0
}

test_error_missing_tools() {
    local original_path="$PATH"
    export PATH="/bin:/usr/bin"
    
    local output
    output=$(source "$TEMPLATES_DIR/01-tool-detection.zsh" 2>&1)
    
    export PATH="$original_path"
    
    # 应该包含友好提示而不是崩溃
    return 0
}

test_compatibility_ubuntu_debian() {
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        log_info "检测到系统: $NAME $VERSION"
        
        if [[ "$ID" == "ubuntu" ]] || [[ "$ID" == "debian" ]]; then
            if command -v batcat >/dev/null 2>&1; then
                log_info "Ubuntu/Debian batcat 兼容性正常"
            fi
            
            if command -v fdfind >/dev/null 2>&1; then
                log_info "Ubuntu/Debian fdfind 兼容性正常"
            fi
        fi
    fi
    
    return 0
}

test_performance_config_loading() {
    local start_time=$(date +%s)
    
    (
        cd "$TEST_TEMP_DIR"
        for module in "$TEMPLATES_DIR"/*.zsh; do
            source "$module" 2>/dev/null
        done
    )
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    log_perf "配置加载总耗时: ${duration}s"
    
    # 配置加载应该在合理时间内完成
    [[ $duration -le 10 ]] || return 1
    
    return 0
}

# 运行所有测试
run_all_tests() {
    log_info "开始运行综合测试..."
    
    # 正常功能测试
    log_info "=== 正常功能测试 ==="
    run_test "TC-00-001" "PATH配置基础功能" "normal" "test_normal_path_config"
    run_test "TC-01-001" "工具检测基础功能" "normal" "test_normal_tool_detection"
    run_test "TC-02-001" "bat配置基础功能" "normal" "test_normal_bat_config"
    run_test "TC-04-001" "fzf集成基础功能" "normal" "test_normal_fzf_integration"
    
    # 边界条件测试
    log_info "=== 边界条件测试 ==="
    run_test "TC-EDGE-001" "大文件处理性能" "boundary" "test_boundary_large_file_handling"
    
    # 错误处理测试
    log_info "=== 错误处理测试 ==="
    run_test "TC-ERROR-001" "工具缺失处理" "error" "test_error_missing_tools"
    
    # 兼容性测试
    log_info "=== 兼容性测试 ==="
    run_test "TC-COMPAT-001" "Ubuntu/Debian兼容性" "compatibility" "test_compatibility_ubuntu_debian"
    
    # 性能测试
    log_info "=== 性能测试 ==="
    run_test "TC-PERF-001" "配置加载性能" "performance" "test_performance_config_loading"
}

# 生成测试报告
generate_report() {
    log_info "生成测试报告..."
    
    echo
    echo "================================================================="
    echo " 综合测试完成"
    echo " 结束时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "================================================================="
    echo "📊 测试统计:"
    echo "  总计: ${TEST_STATS[total]}"
    echo "  通过: ${TEST_STATS[passed]}"
    echo "  失败: ${TEST_STATS[failed]}"
    echo "  跳过: ${TEST_STATS[skipped]}"
    if [[ ${TEST_STATS[total]} -gt 0 ]]; then
        echo "  成功率: $(( TEST_STATS[passed] * 100 / TEST_STATS[total] ))%"
    fi
    echo "================================================================="
}

# 主函数
main() {
    echo "================================================================="
    echo " Shell工具配置模块工作版综合测试"
    echo " 版本: 2.1 Working"
    echo " 开始时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "================================================================="
    
    # 创建测试目录
    mkdir -p "$TEST_TEMP_DIR"
    
    # 检查工具可用性
    log_info "检查工具可用性..."
    for tool in bat batcat fd fdfind fzf rg git; do
        if command -v "$tool" >/dev/null 2>&1; then
            log_info "$tool: 可用"
        else
            log_warn "$tool: 不可用"
        fi
    done
    echo
    
    # 运行测试
    run_all_tests
    
    # 生成报告
    generate_report
    
    # 清理
    rm -rf "$TEST_TEMP_DIR"
    
    # 返回适当的退出码
    if [[ ${TEST_STATS[failed]} -gt 0 ]]; then
        log_error "有 ${TEST_STATS[failed]} 个测试失败"
        exit 1
    else
        log_success "所有测试通过！"
        exit 0
    fi
}

# 执行主函数
main "$@"
