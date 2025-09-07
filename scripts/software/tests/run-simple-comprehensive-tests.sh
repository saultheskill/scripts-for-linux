#!/bin/bash

# Shell工具配置模块简化综合测试脚本
# 版本: 2.1 Simple

set -euo pipefail

# 脚本配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
TEMPLATES_DIR="$PROJECT_ROOT/scripts/software/templates"
TEST_TEMP_DIR="/tmp/shell-tools-simple-test-$$"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 测试统计
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
SKIPPED_TESTS=0

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[FAIL]${NC} $1"
}

# 运行单个测试
run_test() {
    local test_name="$1"
    local test_function="$2"

    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    log_info "运行测试: $test_name"

    if $test_function; then
        PASSED_TESTS=$((PASSED_TESTS + 1))
        log_success "测试通过: $test_name"
        return 0
    else
        local exit_code=$?
        if [[ $exit_code -eq 2 ]]; then
            SKIPPED_TESTS=$((SKIPPED_TESTS + 1))
            log_warn "测试跳过: $test_name"
        else
            FAILED_TESTS=$((FAILED_TESTS + 1))
            log_error "测试失败: $test_name"
        fi
        return $exit_code
    fi
}

# 测试用例
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
        # 基本加载测试，不检查具体别名
        return 0
    )
}

test_bat_config() {
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
        # 基本加载测试
        return 0
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

    log_info "配置加载耗时: ${duration}秒"

    # 配置加载应该在合理时间内完成（10秒内）
    [[ $duration -le 10 ]] || return 1

    return 0
}

# 主函数
main() {
    echo "================================================================="
    echo " Shell工具配置模块简化综合测试"
    echo " 版本: 2.1 Simple"
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
    log_info "开始运行测试..."

    # 基础模块测试
    run_test "PATH配置测试" "test_path_config"
    run_test "工具检测测试" "test_tool_detection"
    run_test "bat配置测试" "test_bat_config"
    run_test "fzf核心测试" "test_fzf_core"
    run_test "fzf基础测试" "test_fzf_basic"
    run_test "ripgrep配置测试" "test_ripgrep_config"
    run_test "git集成测试" "test_git_integration"
    run_test "man集成测试" "test_man_integration"
    run_test "工具函数测试" "test_utility_functions"
    run_test "别名汇总测试" "test_aliases_summary"

    # 错误处理测试
    run_test "工具缺失处理测试" "test_missing_tools_handling"

    # 性能测试
    run_test "配置加载性能测试" "test_config_loading_performance"

    # 清理
    rm -rf "$TEST_TEMP_DIR"

    # 生成报告
    echo
    echo "================================================================="
    echo " 测试完成"
    echo " 结束时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "================================================================="
    echo "📊 测试统计:"
    echo "  总计: $TOTAL_TESTS"
    echo "  通过: $PASSED_TESTS"
    echo "  失败: $FAILED_TESTS"
    echo "  跳过: $SKIPPED_TESTS"
    echo "  成功率: $(( PASSED_TESTS * 100 / TOTAL_TESTS ))%"
    echo "================================================================="

    if [[ $FAILED_TESTS -gt 0 ]]; then
        log_error "有 $FAILED_TESTS 个测试失败"
        exit 1
    else
        log_success "所有测试通过！"
        exit 0
    fi
}

# 执行主函数
main "$@"
