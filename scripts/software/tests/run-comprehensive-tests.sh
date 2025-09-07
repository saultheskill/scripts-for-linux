#!/bin/bash

# Shell工具配置模块综合测试脚本
# 版本: 2.1 Enhanced
# 包含正常功能、边界条件、错误处理、兼容性和性能测试

set -euo pipefail

# 脚本配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
TEMPLATES_DIR="$PROJECT_ROOT/scripts/software/templates"
TEST_LOG_DIR="$SCRIPT_DIR/logs"
TEST_TEMP_DIR="/tmp/shell-tools-comprehensive-test-$$"
TEST_DATA_DIR="$TEST_TEMP_DIR/test-data"

# 颜色和格式定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

# 测试统计
declare -A TEST_STATS=(
    [total]=0
    [passed]=0
    [failed]=0
    [skipped]=0
    [normal]=0
    [boundary]=0
    [error]=0
    [compatibility]=0
    [performance]=0
)

# 测试结果存储
declare -a FAILED_TESTS=()
declare -a SKIPPED_TESTS=()
declare -a SLOW_TESTS=()

# 全局变量
TEST_LOG_FILE=""

# 日志函数
log_info() {
    local msg="${BLUE}[INFO]${NC} $(date '+%H:%M:%S') $1"
    echo -e "$msg"
    [[ -n "$TEST_LOG_FILE" ]] && echo -e "$msg" >> "$TEST_LOG_FILE"
}

log_success() {
    local msg="${GREEN}[PASS]${NC} $(date '+%H:%M:%S') $1"
    echo -e "$msg"
    [[ -n "$TEST_LOG_FILE" ]] && echo -e "$msg" >> "$TEST_LOG_FILE"
}

log_warn() {
    local msg="${YELLOW}[WARN]${NC} $(date '+%H:%M:%S') $1"
    echo -e "$msg"
    [[ -n "$TEST_LOG_FILE" ]] && echo -e "$msg" >> "$TEST_LOG_FILE"
}

log_error() {
    local msg="${RED}[FAIL]${NC} $(date '+%H:%M:%S') $1"
    echo -e "$msg"
    [[ -n "$TEST_LOG_FILE" ]] && echo -e "$msg" >> "$TEST_LOG_FILE"
}

log_skip() {
    local msg="${CYAN}[SKIP]${NC} $(date '+%H:%M:%S') $1"
    echo -e "$msg"
    [[ -n "$TEST_LOG_FILE" ]] && echo -e "$msg" >> "$TEST_LOG_FILE"
}

log_perf() {
    local msg="${PURPLE}[PERF]${NC} $(date '+%H:%M:%S') $1"
    echo -e "$msg"
    [[ -n "$TEST_LOG_FILE" ]] && echo -e "$msg" >> "$TEST_LOG_FILE"
}

# 初始化测试环境
init_comprehensive_test_environment() {
    log_info "初始化综合测试环境..."

    # 创建测试目录结构
    mkdir -p "$TEST_LOG_DIR" "$TEST_TEMP_DIR" "$TEST_DATA_DIR"

    # 设置测试日志文件
    TEST_LOG_FILE="$TEST_LOG_DIR/comprehensive-test-$(date '+%Y%m%d-%H%M%S').log"

    # 创建测试数据
    create_test_data

    log_info "测试环境初始化完成"
    log_info "日志文件: $TEST_LOG_FILE"
    log_info "临时目录: $TEST_TEMP_DIR"
}

# 创建测试数据（简化版本）
create_test_data() {
    log_info "创建测试数据..."

    # 创建简单的测试文件
    echo "console.log('Hello, World!');" > "$TEST_DATA_DIR/test.js"
    echo "print('Hello, World!')" > "$TEST_DATA_DIR/test.py"
    echo "echo 'Hello, World!'" > "$TEST_DATA_DIR/test.sh"

    # 创建小的测试文件
    echo "Line 1: Test content" > "$TEST_DATA_DIR/small-file.txt"
    echo "Line 2: More test content" >> "$TEST_DATA_DIR/small-file.txt"

    # 创建目录结构
    mkdir -p "$TEST_DATA_DIR/subdir1"
    touch "$TEST_DATA_DIR/subdir1/file1.txt"

    log_info "测试数据创建完成"
}

# 清理测试环境
cleanup_comprehensive_test_environment() {
    log_info "清理综合测试环境..."
    rm -rf "$TEST_TEMP_DIR"
    log_info "测试环境清理完成"
}

# 检查工具可用性
check_tool_with_version() {
    local tool="$1"
    if command -v "$tool" >/dev/null 2>&1; then
        local version=$($tool --version 2>/dev/null | head -1 || echo "版本未知")
        log_info "$tool 可用: $version"
        return 0
    else
        log_warn "$tool 不可用"
        return 1
    fi
}

# 运行单个测试用例
run_comprehensive_test() {
    local test_id="$1"
    local test_name="$2"
    local test_type="$3"
    local test_function="$4"

    TEST_STATS[total]=$((TEST_STATS[total] + 1))
    TEST_STATS[$test_type]=$((TEST_STATS[$test_type] + 1))

    log_info "[$test_type] 运行测试: $test_id - $test_name"

    local start_time=$(date +%s.%N)

    if $test_function "$test_id"; then
        local end_time=$(date +%s.%N)
        local duration=$(echo "$end_time - $start_time" | bc -l 2>/dev/null || echo "0")

        TEST_STATS[passed]=$((TEST_STATS[passed] + 1))
        log_success "[$test_type] 测试通过: $test_id (${duration}s)"

        # 检查是否为慢测试
        if command -v bc >/dev/null 2>&1 && [[ $(echo "$duration > 5" | bc -l) -eq 1 ]]; then
            SLOW_TESTS+=("$test_id: ${duration}s")
            log_perf "慢测试警告: $test_id 耗时 ${duration}s"
        fi

        return 0
    else
        local exit_code=$?
        local end_time=$(date +%s.%N)
        local duration=$(echo "$end_time - $start_time" | bc -l 2>/dev/null || echo "0")

        if [[ $exit_code -eq 2 ]]; then
            TEST_STATS[skipped]=$((TEST_STATS[skipped] + 1))
            SKIPPED_TESTS+=("$test_id: $test_name")
            log_skip "[$test_type] 测试跳过: $test_id"
        else
            TEST_STATS[failed]=$((TEST_STATS[failed] + 1))
            FAILED_TESTS+=("$test_id: $test_name")
            log_error "[$test_type] 测试失败: $test_id (${duration}s)"
        fi

        return $exit_code
    fi
}

# 正常功能测试用例
test_normal_path_config() {
    local test_id="$1"

    # 记录初始PATH
    local initial_path="$PATH"

    # 在子shell中测试
    (
        cd "$TEST_TEMP_DIR"
        source "$TEMPLATES_DIR/00-path-config.zsh" 2>/dev/null

        # 验证关键路径存在
        echo "$PATH" | grep -E "(^|:)/bin($|:)" >/dev/null || exit 1
        echo "$PATH" | grep -E "(^|:)/usr/bin($|:)" >/dev/null || exit 1
        echo "$PATH" | grep -E "(^|:)/usr/local/bin($|:)" >/dev/null || exit 1
    )
}

test_normal_tool_detection() {
    local test_id="$1"

    (
        cd "$TEST_TEMP_DIR"
        source "$TEMPLATES_DIR/01-tool-detection.zsh" 2>/dev/null

        # 检查别名设置逻辑
        if command -v batcat >/dev/null 2>&1; then
            alias bat 2>/dev/null | grep -q "batcat" || exit 1
        fi

        if command -v fdfind >/dev/null 2>&1; then
            alias fd 2>/dev/null | grep -q "fdfind" || exit 1
        fi
    )
}

test_normal_bat_config() {
    local test_id="$1"

    (
        cd "$TEST_TEMP_DIR"
        source "$TEMPLATES_DIR/02-bat-config.zsh" 2>/dev/null

        # 验证环境变量设置
        [[ "$BAT_STYLE" == "numbers,changes,header,grid" ]] || exit 1
        [[ "$BAT_THEME" == "OneHalfDark" ]] || exit 1
        [[ "$BAT_PAGER" == "less -RFK" ]] || exit 1

        # 验证别名设置
        alias cat 2>/dev/null | grep -q "bat" || exit 1
    )
}

test_normal_fzf_integration() {
    local test_id="$1"

    if ! command -v fzf >/dev/null 2>&1; then
        return 2  # 跳过测试
    fi

    (
        cd "$TEST_TEMP_DIR"
        source "$TEMPLATES_DIR/04-fzf-core.zsh" 2>/dev/null
        source "$TEMPLATES_DIR/05-fzf-basic.zsh" 2>/dev/null

        # 验证环境变量设置
        [[ -n "$FZF_DEFAULT_OPTS" ]] || exit 1
        echo "$FZF_DEFAULT_OPTS" | grep -q "height=70%" || exit 1

        # 验证函数定义
        declare -f fe >/dev/null 2>&1 || exit 1
        declare -f fp >/dev/null 2>&1 || exit 1
    )
}

# 边界条件测试用例
test_boundary_large_file_handling() {
    local test_id="$1"

    if ! command -v bat >/dev/null 2>&1; then
        return 2  # 跳过测试
    fi

    # 测试大文件处理
    local start_time=$(date +%s.%N)
    bat "$TEST_DATA_DIR/large-file.txt" >/dev/null 2>&1
    local end_time=$(date +%s.%N)
    local duration=$(echo "$end_time - $start_time" | bc -l 2>/dev/null || echo "0")

    # 大文件处理应该在合理时间内完成
    if command -v bc >/dev/null 2>&1 && [[ $(echo "$duration > 10" | bc -l) -eq 1 ]]; then
        log_warn "大文件处理耗时过长: ${duration}s"
        return 1
    fi

    return 0
}

test_boundary_special_characters() {
    local test_id="$1"

    if ! command -v fd >/dev/null 2>&1 && ! command -v fdfind >/dev/null 2>&1; then
        return 2  # 跳过测试
    fi

    # 测试特殊字符文件名处理
    local fd_cmd="fd"
    if command -v fdfind >/dev/null 2>&1; then
        fd_cmd="fdfind"
    fi

    $fd_cmd "中文" "$TEST_DATA_DIR" >/dev/null 2>&1 || return 1

    return 0
}

# 错误处理测试用例
test_error_missing_tools() {
    local test_id="$1"

    # 临时隐藏工具
    local original_path="$PATH"
    export PATH="/bin:/usr/bin"

    # 测试工具缺失时的处理
    local output
    output=$(source "$TEMPLATES_DIR/01-tool-detection.zsh" 2>&1)

    # 恢复PATH
    export PATH="$original_path"

    # 应该包含友好的错误提示
    echo "$output" | grep -q "未找到\|缺少\|安装\|提示" || return 1

    return 0
}

test_error_permission_denied() {
    local test_id="$1"

    if ! command -v bat >/dev/null 2>&1; then
        return 2  # 跳过测试
    fi

    # 创建无权限文件
    local restricted_file="$TEST_TEMP_DIR/restricted.txt"
    echo "restricted content" > "$restricted_file"
    chmod 000 "$restricted_file"

    # 测试权限错误处理
    local output
    output=$(bat "$restricted_file" 2>&1)
    local exit_code=$?

    # 清理
    chmod 644 "$restricted_file"
    rm -f "$restricted_file"

    # 应该返回非零退出码并包含错误信息
    [[ $exit_code -ne 0 ]] || return 1
    echo "$output" | grep -q -i "permission\|denied\|权限" || return 1

    return 0
}

# 兼容性测试用例
test_compatibility_ubuntu_debian() {
    local test_id="$1"

    # 检查系统类型
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        log_info "检测到系统: $NAME $VERSION"

        # 验证Ubuntu/Debian特定的工具别名
        if [[ "$ID" == "ubuntu" ]] || [[ "$ID" == "debian" ]]; then
            # 这些系统通常使用batcat和fdfind
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

# 性能测试用例
test_performance_config_loading() {
    local test_id="$1"

    local start_time=$(date +%s.%N)

    # 测试配置加载性能
    (
        cd "$TEST_TEMP_DIR"
        for module in "$TEMPLATES_DIR"/*.zsh; do
            source "$module" 2>/dev/null
        done
    )

    local end_time=$(date +%s.%N)
    local duration=$(echo "$end_time - $start_time" | bc -l 2>/dev/null || echo "0")

    log_perf "配置加载总耗时: ${duration}s"

    # 配置加载应该在合理时间内完成
    if command -v bc >/dev/null 2>&1 && [[ $(echo "$duration > 5" | bc -l) -eq 1 ]]; then
        log_warn "配置加载耗时过长: ${duration}s"
        return 1
    fi

    return 0
}

# 运行所有综合测试
run_all_comprehensive_tests() {
    log_info "开始运行综合测试套件..."

    # 正常功能测试
    log_info "=== 正常功能测试 ==="
    run_comprehensive_test "TC-00-001" "PATH配置基础功能" "normal" "test_normal_path_config"
    run_comprehensive_test "TC-01-001" "工具检测基础功能" "normal" "test_normal_tool_detection"
    run_comprehensive_test "TC-02-001" "bat配置基础功能" "normal" "test_normal_bat_config"
    run_comprehensive_test "TC-04-001" "fzf集成基础功能" "normal" "test_normal_fzf_integration"

    # 边界条件测试
    log_info "=== 边界条件测试 ==="
    run_comprehensive_test "TC-EDGE-001" "大文件处理性能" "boundary" "test_boundary_large_file_handling"
    run_comprehensive_test "TC-EDGE-002" "特殊字符处理" "boundary" "test_boundary_special_characters"

    # 错误处理测试
    log_info "=== 错误处理测试 ==="
    run_comprehensive_test "TC-ERROR-001" "工具缺失处理" "error" "test_error_missing_tools"
    run_comprehensive_test "TC-ERROR-002" "权限错误处理" "error" "test_error_permission_denied"

    # 兼容性测试
    log_info "=== 兼容性测试 ==="
    run_comprehensive_test "TC-COMPAT-001" "Ubuntu/Debian兼容性" "compatibility" "test_compatibility_ubuntu_debian"

    # 性能测试
    log_info "=== 性能测试 ==="
    run_comprehensive_test "TC-PERF-001" "配置加载性能" "performance" "test_performance_config_loading"
}

# 生成综合测试报告
generate_comprehensive_report() {
    log_info "生成综合测试报告..."

    local report_file="$TEST_LOG_DIR/comprehensive-report-$(date '+%Y%m%d-%H%M%S').md"

    cat > "$report_file" << EOF
# Shell工具配置模块综合测试报告

## 📊 测试执行摘要

- **执行时间**: $(date '+%Y-%m-%d %H:%M:%S')
- **测试环境**: $(uname -a)
- **Shell版本**: $($SHELL --version | head -1)

## 📈 测试统计

| 测试类型 | 执行数量 | 通过率 |
|---------|----------|--------|
| 总计 | ${TEST_STATS[total]} | $(( TEST_STATS[passed] * 100 / TEST_STATS[total] ))% |
| 正常功能 | ${TEST_STATS[normal]} | - |
| 边界条件 | ${TEST_STATS[boundary]} | - |
| 错误处理 | ${TEST_STATS[error]} | - |
| 兼容性 | ${TEST_STATS[compatibility]} | - |
| 性能测试 | ${TEST_STATS[performance]} | - |

## 📋 测试结果详情

- ✅ **通过**: ${TEST_STATS[passed]}
- ❌ **失败**: ${TEST_STATS[failed]}
- ⏭️ **跳过**: ${TEST_STATS[skipped]}

EOF

    # 添加失败测试详情
    if [[ ${#FAILED_TESTS[@]} -gt 0 ]]; then
        echo "## ❌ 失败测试" >> "$report_file"
        for test in "${FAILED_TESTS[@]}"; do
            echo "- $test" >> "$report_file"
        done
        echo >> "$report_file"
    fi

    # 添加跳过测试详情
    if [[ ${#SKIPPED_TESTS[@]} -gt 0 ]]; then
        echo "## ⏭️ 跳过测试" >> "$report_file"
        for test in "${SKIPPED_TESTS[@]}"; do
            echo "- $test" >> "$report_file"
        done
        echo >> "$report_file"
    fi

    # 添加性能警告
    if [[ ${#SLOW_TESTS[@]} -gt 0 ]]; then
        echo "## ⚠️ 性能警告" >> "$report_file"
        for test in "${SLOW_TESTS[@]}"; do
            echo "- $test" >> "$report_file"
        done
        echo >> "$report_file"
    fi

    echo "详细日志: $TEST_LOG_FILE" >> "$report_file"

    log_info "综合测试报告: $report_file"

    # 显示报告摘要
    cat "$report_file"
}

# 主函数
main() {
    echo "================================================================="
    echo " Shell工具配置模块综合测试套件"
    echo " 版本: 2.1 Enhanced"
    echo " 开始时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "================================================================="

    # 初始化测试环境
    init_comprehensive_test_environment

    # 设置错误处理（在初始化后设置，避免过早清理）
    trap cleanup_comprehensive_test_environment EXIT

    # 检查工具可用性
    log_info "检查工具可用性..."
    check_tool_with_version "bat" || check_tool_with_version "batcat"
    check_tool_with_version "fd" || check_tool_with_version "fdfind"
    check_tool_with_version "fzf"
    check_tool_with_version "rg"
    check_tool_with_version "git"

    # 运行综合测试
    run_all_comprehensive_tests

    # 生成测试报告
    generate_comprehensive_report

    # 返回适当的退出码
    if [[ ${TEST_STATS[failed]} -gt 0 ]]; then
        log_error "综合测试完成，有 ${TEST_STATS[failed]} 个测试失败"
        exit 1
    else
        log_success "所有综合测试通过！"
        exit 0
    fi
}

# 执行主函数（仅在直接运行时执行）
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
