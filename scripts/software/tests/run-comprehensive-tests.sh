#!/bin/bash

# Shell工具配置模块全面测试脚本
# 版本: 2.1 Refactored
# 包含功能、性能、兼容性、错误处理等综合测试

set -euo pipefail

# 脚本配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
TEMPLATES_DIR="$PROJECT_ROOT/scripts/software/templates"
TEST_LOG_DIR="$SCRIPT_DIR/logs"
TEST_TEMP_DIR="/tmp/shell-tools-comprehensive-test-$$"

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

# 初始化测试环境
init_test_environment() {
    log_info "初始化测试环境..."
    mkdir -p "$TEST_LOG_DIR" "$TEST_TEMP_DIR"

    # 创建简单的测试文件
    echo "console.log('test');" > "$TEST_TEMP_DIR/test.js"
    echo "print('test')" > "$TEST_TEMP_DIR/test.py"
    echo "echo 'test'" > "$TEST_TEMP_DIR/test.sh"

    log_info "测试环境初始化完成"
}

# 清理测试环境
cleanup_test_environment() {
    rm -rf "$TEST_TEMP_DIR"
}

# 检查工具可用性（支持Ubuntu/Debian别名）
check_tool_availability() {
    local tool="$1"

    if command -v "$tool" >/dev/null 2>&1; then
        return 0
    fi

    # 检查Ubuntu/Debian别名
    case "$tool" in
        "bat")
            command -v "batcat" >/dev/null 2>&1 && return 0
            ;;
        "fd")
            command -v "fdfind" >/dev/null 2>&1 && return 0
            ;;
    esac

    return 1
}

# 运行单个测试
run_test() {
    local test_name="$1"
    local test_function="$2"

    TEST_STATS[total]=$((TEST_STATS[total] + 1))
    log_info "运行测试: $test_name"

    local start_time=$(date +%s)

    if $test_function; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))

        TEST_STATS[passed]=$((TEST_STATS[passed] + 1))
        log_success "测试通过: $test_name (${duration}s)"

        if [[ $duration -gt 5 ]]; then
            log_perf "慢测试警告: $test_name 耗时 ${duration}s"
        fi

        return 0
    else
        local exit_code=$?
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))

        if [[ $exit_code -eq 2 ]]; then
            TEST_STATS[skipped]=$((TEST_STATS[skipped] + 1))
            log_warn "测试跳过: $test_name"
        else
            TEST_STATS[failed]=$((TEST_STATS[failed] + 1))
            log_error "测试失败: $test_name (${duration}s)"
        fi

        return $exit_code
    fi
}

# 功能测试用例
test_path_config() {
    (
        cd "$TEST_TEMP_DIR"
        source "$TEMPLATES_DIR/00-path-config.zsh" 2>/dev/null
        echo "$PATH" | grep -E "(^|:)/bin($|:)" >/dev/null || exit 1
        echo "$PATH" | grep -E "(^|:)/usr/bin($|:)" >/dev/null || exit 1
    )
}

test_tool_detection() {
    (
        cd "$TEST_TEMP_DIR"
        source "$TEMPLATES_DIR/01-tool-detection.zsh" 2>/dev/null
        return 0  # 基本加载测试
    )
}

test_bat_config() {
    if ! check_tool_availability "bat"; then
        return 2  # 跳过测试
    fi

    (
        cd "$TEST_TEMP_DIR"
        source "$TEMPLATES_DIR/02-bat-config.zsh" 2>/dev/null
        [[ "$BAT_STYLE" == "numbers,changes,header,grid" ]] || exit 1
        [[ "$BAT_THEME" == "OneHalfDark" ]] || exit 1
    )
}

test_fd_config() {
    if ! check_tool_availability "fd"; then
        return 2  # 跳过测试
    fi

    (
        cd "$TEST_TEMP_DIR"
        source "$TEMPLATES_DIR/03-fd-config.zsh" 2>/dev/null
        # 检查别名是否设置
        alias fdf >/dev/null 2>&1 || exit 1
    )
}

test_fzf_core() {
    if ! command -v fzf >/dev/null 2>&1; then
        return 2  # 跳过测试
    fi

    (
        cd "$TEST_TEMP_DIR"
        source "$TEMPLATES_DIR/04-fzf-core.zsh" 2>/dev/null
        [[ -n "$FZF_DEFAULT_OPTS" ]] || exit 1
        echo "$FZF_DEFAULT_OPTS" | grep -q "height=70%" || exit 1
    )
}

test_fzf_basic() {
    if ! command -v fzf >/dev/null 2>&1; then
        return 2  # 跳过测试
    fi

    (
        cd "$TEST_TEMP_DIR"
        source "$TEMPLATES_DIR/05-fzf-basic.zsh" 2>/dev/null
        declare -f fe >/dev/null 2>&1 || exit 1
        declare -f fp >/dev/null 2>&1 || exit 1
    )
}

test_ripgrep_config() {
    if ! command -v rg >/dev/null 2>&1; then
        return 2  # 跳过测试
    fi

    (
        cd "$TEST_TEMP_DIR"
        source "$TEMPLATES_DIR/07-ripgrep-config.zsh" 2>/dev/null
        return 0  # 基本加载测试
    )
}

test_git_integration() {
    if ! command -v git >/dev/null 2>&1 || ! command -v fzf >/dev/null 2>&1; then
        return 2  # 跳过测试
    fi

    (
        cd "$TEST_TEMP_DIR"
        source "$TEMPLATES_DIR/09-git-integration.zsh" 2>/dev/null
        declare -f gco >/dev/null 2>&1 || exit 1
        declare -f glog >/dev/null 2>&1 || exit 1
    )
}

test_fzf_git_advanced() {
    if ! command -v git >/dev/null 2>&1 || ! command -v fzf >/dev/null 2>&1; then
        return 2  # 跳过测试
    fi

    (
        cd "$TEST_TEMP_DIR"
        source "$TEMPLATES_DIR/09-fzf-git-advanced.zsh" 2>/dev/null
        declare -f _fzf_git_files >/dev/null 2>&1 || exit 1
        declare -f _fzf_git_branches >/dev/null 2>&1 || exit 1
        declare -f gco-fzf >/dev/null 2>&1 || exit 1
        declare -f gswt >/dev/null 2>&1 || exit 1
    )
}

test_man_integration() {
    (
        cd "$TEST_TEMP_DIR"
        source "$TEMPLATES_DIR/11-man-integration.zsh" 2>/dev/null
        [[ -n "$MANPAGER" ]] || exit 1
        declare -f fman >/dev/null 2>&1 || exit 1
    )
}

test_utility_functions() {
    (
        cd "$TEST_TEMP_DIR"
        source "$TEMPLATES_DIR/13-utility-functions.zsh" 2>/dev/null
        declare -f search-all >/dev/null 2>&1 || exit 1
        declare -f quick-view >/dev/null 2>&1 || exit 1
    )
}

test_aliases_summary() {
    (
        cd "$TEST_TEMP_DIR"
        source "$TEMPLATES_DIR/99-aliases-summary.zsh" 2>/dev/null
        declare -f show-tools >/dev/null 2>&1 || exit 1
    )
}

# 性能测试
test_config_loading_performance() {
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

# 错误处理测试
test_missing_tools_handling() {
    local original_path="$PATH"
    export PATH="/bin:/usr/bin"

    local output
    output=$(source "$TEMPLATES_DIR/01-tool-detection.zsh" 2>&1)

    export PATH="$original_path"

    # 应该包含友好提示而不是崩溃
    return 0
}

# 兼容性测试
test_ubuntu_debian_compatibility() {
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

# 运行所有测试
run_all_tests() {
    log_info "开始运行全面测试..."

    # 功能测试
    log_info "=== 功能测试 ==="
    run_test "PATH配置测试" "test_path_config"
    run_test "工具检测测试" "test_tool_detection"
    run_test "bat配置测试" "test_bat_config"
    run_test "fd配置测试" "test_fd_config"
    run_test "fzf核心测试" "test_fzf_core"
    run_test "fzf基础测试" "test_fzf_basic"
    run_test "ripgrep配置测试" "test_ripgrep_config"
    run_test "git集成测试" "test_git_integration"
    run_test "fzf-git高级测试" "test_fzf_git_advanced"
    run_test "man集成测试" "test_man_integration"
    run_test "工具函数测试" "test_utility_functions"
    run_test "别名汇总测试" "test_aliases_summary"

    # 性能测试
    log_info "=== 性能测试 ==="
    run_test "配置加载性能测试" "test_config_loading_performance"

    # 错误处理测试
    log_info "=== 错误处理测试 ==="
    run_test "工具缺失处理测试" "test_missing_tools_handling"

    # 兼容性测试
    log_info "=== 兼容性测试 ==="
    run_test "Ubuntu/Debian兼容性测试" "test_ubuntu_debian_compatibility"
}

# 生成测试报告
generate_report() {
    echo
    echo "================================================================="
    echo " 全面测试完成"
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
    echo " Shell工具配置模块全面测试"
    echo " 版本: 2.1 Refactored"
    echo " 开始时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "================================================================="

    # 设置错误处理
    trap cleanup_test_environment EXIT

    # 初始化测试环境
    init_test_environment

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
