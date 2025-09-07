#!/bin/bash

# Shell工具配置模块自动化测试脚本
# 版本: 2.1
# 作者: saul

set -euo pipefail

# 脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
TEMPLATES_DIR="$PROJECT_ROOT/scripts/software/templates"
TEST_LOG_DIR="$SCRIPT_DIR/logs"
TEST_TEMP_DIR="/tmp/shell-tools-test-$$"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 测试统计
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
SKIPPED_TESTS=0

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $(date '+%Y-%m-%d %H:%M:%S') $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $(date '+%Y-%m-%d %H:%M:%S') $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $(date '+%Y-%m-%d %H:%M:%S') $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $(date '+%Y-%m-%d %H:%M:%S') $1"
}

# 初始化测试环境
init_test_environment() {
    log_info "初始化测试环境..."

    # 创建测试目录
    mkdir -p "$TEST_LOG_DIR" "$TEST_TEMP_DIR"

    # 设置测试日志文件
    TEST_LOG_FILE="$TEST_LOG_DIR/test-$(date '+%Y%m%d-%H%M%S').log"
    exec 1> >(tee -a "$TEST_LOG_FILE")
    exec 2> >(tee -a "$TEST_LOG_FILE" >&2)

    log_info "测试日志: $TEST_LOG_FILE"
    log_info "临时目录: $TEST_TEMP_DIR"
}

# 清理测试环境
cleanup_test_environment() {
    log_info "清理测试环境..."
    rm -rf "$TEST_TEMP_DIR"
}

# 检查工具可用性（支持Ubuntu/Debian别名）
check_tool_availability() {
    local tool="$1"

    # 直接检查工具
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

# 测试模块加载
test_module_loading() {
    local module_file="$1"
    local module_path="$TEMPLATES_DIR/$module_file"

    if [[ ! -f "$module_path" ]]; then
        log_error "模块文件不存在: $module_path"
        return 1
    fi

    # 在子shell中测试加载
    if (cd "$TEST_TEMP_DIR" && source "$module_path" 2>/dev/null); then
        return 0
    else
        log_error "模块加载失败: $module_file"
        return 1
    fi
}

# 测试工具依赖
test_tool_dependencies() {
    local module_file="$1"
    shift
    local required_tools=("$@")

    if [[ ${#required_tools[@]} -eq 0 ]]; then
        return 0  # 无依赖要求
    fi

    local missing_tools=()
    for tool in "${required_tools[@]}"; do
        if ! check_tool_availability "$tool"; then
            missing_tools+=("$tool")
        fi
    done

    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        log_warn "模块 $module_file 缺少工具: ${missing_tools[*]}"
        return 2  # 跳过测试
    fi

    return 0
}

# 测试别名设置
test_aliases() {
    local module_file="$1"
    shift
    local expected_aliases=("$@")

    if [[ ${#expected_aliases[@]} -eq 0 ]]; then
        return 0  # 无别名要求
    fi

    # 在子shell中加载模块并测试别名
    (
        cd "$TEST_TEMP_DIR"
        source "$TEMPLATES_DIR/$module_file" 2>/dev/null

        local failed_aliases=()
        for alias_name in "${expected_aliases[@]}"; do
            if ! alias "$alias_name" >/dev/null 2>&1; then
                failed_aliases+=("$alias_name")
            fi
        done

        if [[ ${#failed_aliases[@]} -gt 0 ]]; then
            log_error "别名设置失败: ${failed_aliases[*]}"
            return 1
        fi

        return 0
    )
}

# 测试函数定义
test_functions() {
    local module_file="$1"
    shift
    local expected_functions=("$@")

    if [[ ${#expected_functions[@]} -eq 0 ]]; then
        return 0  # 无函数要求
    fi

    # 在子shell中加载模块并测试函数
    (
        cd "$TEST_TEMP_DIR"
        source "$TEMPLATES_DIR/$module_file" 2>/dev/null

        local failed_functions=()
        for func_name in "${expected_functions[@]}"; do
            if ! declare -f "$func_name" >/dev/null 2>&1; then
                failed_functions+=("$func_name")
            fi
        done

        if [[ ${#failed_functions[@]} -gt 0 ]]; then
            log_error "函数定义失败: ${failed_functions[*]}"
            return 1
        fi

        return 0
    )
}

# 具体功能测试函数
test_path_functionality() {
    (
        cd "$TEST_TEMP_DIR"
        source "$TEMPLATES_DIR/00-path-config.zsh" 2>/dev/null

        # 验证PATH重复添加防护
        local initial_count=$(echo "$PATH" | tr ':' '\n' | wc -l)
        source "$TEMPLATES_DIR/00-path-config.zsh" 2>/dev/null
        local final_count=$(echo "$PATH" | tr ':' '\n' | wc -l)

        [[ $final_count -le $((initial_count + 5)) ]] || exit 1
    )
}

test_tool_aliases() {
    (
        cd "$TEST_TEMP_DIR"
        source "$TEMPLATES_DIR/01-tool-detection.zsh" 2>/dev/null

        # 检查bat别名（如果batcat存在）
        if command -v batcat >/dev/null 2>&1; then
            alias bat 2>/dev/null | grep -q "batcat" || exit 1
        fi

        # 检查fd别名（如果fdfind存在）
        if command -v fdfind >/dev/null 2>&1; then
            alias fd 2>/dev/null | grep -q "fdfind" || exit 1
        fi
    )
}

test_bat_environment() {
    if ! check_tool_availability "bat"; then
        return 2  # 跳过测试
    fi

    (
        cd "$TEST_TEMP_DIR"
        source "$TEMPLATES_DIR/02-bat-config.zsh" 2>/dev/null

        [[ "$BAT_STYLE" == "numbers,changes,header,grid" ]] || exit 1
        [[ "$BAT_THEME" == "OneHalfDark" ]] || exit 1
        [[ "$BAT_PAGER" == "less -RFK" ]] || exit 1
    )
}

# 模块测试定义
run_module_tests() {
    log_info "开始模块测试..."

    # 模块00: PATH配置测试
    run_test "模块00-PATH配置-加载测试" "test_module_loading 00-path-config.zsh"
    run_test "模块00-PATH配置-功能测试" "test_path_functionality"

    # 模块01: 工具检测测试
    run_test "模块01-工具检测-加载测试" "test_module_loading 01-tool-detection.zsh"
    run_test "模块01-工具检测-依赖测试" "test_tool_dependencies 01-tool-detection.zsh bat fd"
    run_test "模块01-工具检测-别名测试" "test_tool_aliases"

    # 模块02: bat配置测试
    run_test "模块02-bat配置-加载测试" "test_module_loading 02-bat-config.zsh"
    run_test "模块02-bat配置-依赖测试" "test_tool_dependencies 02-bat-config.zsh bat"
    run_test "模块02-bat配置-环境变量测试" "test_bat_environment"
    run_test "模块02-bat配置-别名测试" "test_aliases 02-bat-config.zsh cat less more batl batn batp"

    # 模块03: fd配置测试
    run_test "模块03-fd配置-加载测试" "test_module_loading 03-fd-config.zsh"
    run_test "模块03-fd配置-依赖测试" "test_tool_dependencies 03-fd-config.zsh fd"
    run_test "模块03-fd配置-别名测试" "test_aliases 03-fd-config.zsh fdf fdd fda fdx fds"
    run_test "模块03-fd配置-函数测试" "test_functions 03-fd-config.zsh fdbat fdpreview"

    # 模块04: fzf核心测试
    run_test "模块04-fzf核心-加载测试" "test_module_loading 04-fzf-core.zsh"
    run_test "模块04-fzf核心-依赖测试" "test_tool_dependencies 04-fzf-core.zsh fzf"

    # 模块05: fzf基础测试
    run_test "模块05-fzf基础-加载测试" "test_module_loading 05-fzf-basic.zsh"
    run_test "模块05-fzf基础-依赖测试" "test_tool_dependencies 05-fzf-basic.zsh fzf bat"
    run_test "模块05-fzf基础-函数测试" "test_functions 05-fzf-basic.zsh fe fp fif fcd fh fkill"
    run_test "模块05-fzf基础-别名测试" "test_aliases 05-fzf-basic.zsh ff fed fdir fhist"

    # 模块06: fzf高级测试
    run_test "模块06-fzf高级-加载测试" "test_module_loading 06-fzf-advanced.zsh"
    run_test "模块06-fzf高级-依赖测试" "test_tool_dependencies 06-fzf-advanced.zsh fzf bat fd"
    run_test "模块06-fzf高级-函数测试" "test_functions 06-fzf-advanced.zsh fzf-multi-search fzf-reload"
    run_test "模块06-fzf高级-别名测试" "test_aliases 06-fzf-advanced.zsh fms frl"

    # 模块07: ripgrep配置测试
    run_test "模块07-ripgrep配置-加载测试" "test_module_loading 07-ripgrep-config.zsh"
    run_test "模块07-ripgrep配置-依赖测试" "test_tool_dependencies 07-ripgrep-config.zsh rg"
    run_test "模块07-ripgrep配置-别名测试" "test_aliases 07-ripgrep-config.zsh rgi rgf rgl rgL rgv rgw rgA rgB rgC"
    run_test "模块07-ripgrep配置-函数测试" "test_functions 07-ripgrep-config.zsh rg-py rg-js rg-stats"

    # 模块08: ripgrep+fzf集成测试
    run_test "模块08-ripgrep+fzf-加载测试" "test_module_loading 08-ripgrep-fzf.zsh"
    run_test "模块08-ripgrep+fzf-依赖测试" "test_tool_dependencies 08-ripgrep-fzf.zsh rg fzf bat"
    run_test "模块08-ripgrep+fzf-函数测试" "test_functions 08-ripgrep-fzf.zsh rgf rge rgc rgm rgs"
    run_test "模块08-ripgrep+fzf-别名测试" "test_aliases 08-ripgrep-fzf.zsh rgfzf rged rgctx rgmulti rgreplace"

    # 模块09: git集成测试
    run_test "模块09-git集成-加载测试" "test_module_loading 09-git-integration.zsh"
    run_test "模块09-git集成-依赖测试" "test_tool_dependencies 09-git-integration.zsh git fzf bat"
    run_test "模块09-git集成-函数测试" "test_functions 09-git-integration.zsh _git_checkout_interactive _git_log_interactive _git_status_interactive gstash gremote gfh gblame gdiff git-alias-status"
    run_test "模块09-git集成-别名测试" "test_aliases 09-git-integration.zsh gco glog gst gbr glg gstat gsh grm gfhist gbl gdf gco-orig glog-orig gst-orig gbl-orig"

    # 模块09-fzf-git-advanced: fzf-git高级集成测试
    run_test "模块09-fzf-git高级-加载测试" "test_module_loading 09-fzf-git-advanced.zsh"
    run_test "模块09-fzf-git高级-依赖测试" "test_tool_dependencies 09-fzf-git-advanced.zsh git fzf"
    run_test "模块09-fzf-git高级-函数测试" "test_functions 09-fzf-git-advanced.zsh _fzf_git_files _fzf_git_branches gco-fzf gswt gshow gstash-apply"
    run_test "模块09-fzf-git高级-别名测试" "test_aliases 09-fzf-git-advanced.zsh gco-f gsw gsh-f gst-f"

    # 模块10: 日志监控测试（占位符）
    run_test "模块10-日志监控-加载测试" "test_module_loading 10-log-monitoring.zsh"

    # 模块11: man集成测试
    run_test "模块11-man集成-加载测试" "test_module_loading 11-man-integration.zsh"
    run_test "模块11-man集成-依赖测试" "test_tool_dependencies 11-man-integration.zsh bat fzf"
    run_test "模块11-man集成-函数测试" "test_functions 11-man-integration.zsh fman batman man-search man-help man-section"
    run_test "模块11-man集成-别名测试" "test_aliases 11-man-integration.zsh manf mans manh"

    # 模块12: APT集成测试
    run_test "模块12-APT集成-加载测试" "test_module_loading 12-apt-integration.zsh"
    run_test "模块12-APT集成-依赖测试" "test_tool_dependencies 12-apt-integration.zsh fzf bat"
    run_test "模块12-APT集成-函数测试" "test_functions 12-apt-integration.zsh apt-search apt-installed apt-info"
    run_test "模块12-APT集成-别名测试" "test_aliases 12-apt-integration.zsh af as ai ainfo"

    # 模块13: 工具函数测试
    run_test "模块13-工具函数-加载测试" "test_module_loading 13-utility-functions.zsh"
    run_test "模块13-工具函数-依赖测试" "test_tool_dependencies 13-utility-functions.zsh bat fd rg"
    run_test "模块13-工具函数-函数测试" "test_functions 13-utility-functions.zsh search-all quick-view file-sizes find-duplicates clean-empty"
    run_test "模块13-工具函数-别名测试" "test_aliases 13-utility-functions.zsh sa qv fs fd-dup clean"

    # 模块99: 别名汇总测试
    run_test "模块99-别名汇总-加载测试" "test_module_loading 99-aliases-summary.zsh"
    run_test "模块99-别名汇总-函数测试" "test_functions 99-aliases-summary.zsh show-tools"
    run_test "模块99-别名汇总-别名测试" "test_aliases 99-aliases-summary.zsh tools help-tools st"
}

# 生成测试报告
generate_test_report() {
    log_info "生成测试报告..."

    local report_file="$TEST_LOG_DIR/test-report-$(date '+%Y%m%d-%H%M%S').txt"

    cat > "$report_file" << EOF
=================================================================
Shell工具配置模块测试报告
=================================================================

测试执行时间: $(date '+%Y-%m-%d %H:%M:%S')
测试环境: $(uname -a)
Shell版本: $($SHELL --version | head -1)

测试统计:
- 总测试用例: $TOTAL_TESTS
- 通过用例: $PASSED_TESTS
- 失败用例: $FAILED_TESTS
- 跳过用例: $SKIPPED_TESTS
- 成功率: $(( PASSED_TESTS * 100 / TOTAL_TESTS ))%

工具可用性:
- bat: $(check_tool_availability bat && echo "✓" || echo "✗")
- fd: $(check_tool_availability fd && echo "✓" || echo "✗")
- fzf: $(check_tool_availability fzf && echo "✓" || echo "✗")
- rg: $(check_tool_availability rg && echo "✓" || echo "✗")
- git: $(check_tool_availability git && echo "✓" || echo "✗")

详细日志: $TEST_LOG_FILE
=================================================================
EOF

    log_info "测试报告: $report_file"
    cat "$report_file"
}

# 主函数
main() {
    echo "================================================================="
    echo " Shell工具配置模块自动化测试"
    echo " 版本: 2.1"
    echo " 时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "================================================================="

    # 设置错误处理
    trap cleanup_test_environment EXIT

    # 初始化测试环境
    init_test_environment

    # 运行模块测试
    run_module_tests

    # 生成测试报告
    generate_test_report

    # 返回适当的退出码
    if [[ $FAILED_TESTS -gt 0 ]]; then
        log_error "测试完成，有 $FAILED_TESTS 个测试失败"
        exit 1
    else
        log_success "所有测试通过！"
        exit 0
    fi
}

# 执行主函数
main "$@"
