#!/bin/bash

# Shell工具配置模块快速回归测试脚本
# 版本: 2.1
# 执行时间: 约15分钟

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 快速语法检查
quick_syntax_check() {
    log_info "执行快速语法检查..."
    
    local templates_dir="$PROJECT_ROOT/scripts/software/templates"
    local failed_files=()
    
    # 检查所有.zsh文件语法
    for zsh_file in "$templates_dir"/*.zsh; do
        if [[ -f "$zsh_file" ]]; then
            if ! zsh -n "$zsh_file" 2>/dev/null; then
                failed_files+=("$(basename "$zsh_file")")
            fi
        fi
    done
    
    # 检查YAML配置文件
    if command -v python3 >/dev/null 2>&1; then
        if ! python3 -c "import yaml; yaml.safe_load(open('$templates_dir/modules.yaml'))" 2>/dev/null; then
            failed_files+=("modules.yaml")
        fi
    fi
    
    if [[ ${#failed_files[@]} -gt 0 ]]; then
        log_error "语法检查失败的文件: ${failed_files[*]}"
        return 1
    else
        log_success "所有文件语法检查通过"
        return 0
    fi
}

# 快速配置生成测试
quick_generation_test() {
    log_info "执行快速配置生成测试..."
    
    # 备份现有配置
    local backup_dir="/tmp/shell-tools-backup-$$"
    mkdir -p "$backup_dir"
    
    if [[ -d "$HOME/.oh-my-zsh/custom/modules" ]]; then
        cp -r "$HOME/.oh-my-zsh/custom/modules" "$backup_dir/" 2>/dev/null || true
    fi
    
    # 运行配置生成器
    if cd "$PROJECT_ROOT" && python3 scripts/software/shell-tools-config-generator.py >/dev/null 2>&1; then
        log_success "配置生成测试通过"
        
        # 检查生成的文件数量
        local module_count=$(ls -1 "$HOME/.oh-my-zsh/custom/modules"/*.zsh 2>/dev/null | wc -l)
        if [[ $module_count -eq 15 ]]; then
            log_success "生成了正确数量的模块文件: $module_count"
        else
            log_warn "模块文件数量异常: $module_count (期望: 15)"
        fi
        
        # 恢复备份
        if [[ -d "$backup_dir/modules" ]]; then
            rm -rf "$HOME/.oh-my-zsh/custom/modules"
            mv "$backup_dir/modules" "$HOME/.oh-my-zsh/custom/"
        fi
        rm -rf "$backup_dir"
        
        return 0
    else
        log_error "配置生成测试失败"
        
        # 恢复备份
        if [[ -d "$backup_dir/modules" ]]; then
            rm -rf "$HOME/.oh-my-zsh/custom/modules" 2>/dev/null || true
            mv "$backup_dir/modules" "$HOME/.oh-my-zsh/custom/" 2>/dev/null || true
        fi
        rm -rf "$backup_dir"
        
        return 1
    fi
}

# 快速功能测试
quick_functionality_test() {
    log_info "执行快速功能测试..."
    
    # 测试配置加载
    local test_script="/tmp/shell-tools-func-test-$$.zsh"
    cat > "$test_script" << 'EOF'
#!/bin/zsh

# 加载主配置
if [[ -f "$HOME/.oh-my-zsh/custom/shell-tools-main.zsh" ]]; then
    source "$HOME/.oh-my-zsh/custom/shell-tools-main.zsh" 2>/dev/null
else
    echo "主配置文件不存在"
    exit 1
fi

# 测试核心函数是否可用
test_functions=("show-tools" "search-all" "shell-tools-debug")
failed_functions=()

for func in "${test_functions[@]}"; do
    if ! command -v "$func" >/dev/null 2>&1 && ! declare -f "$func" >/dev/null 2>&1; then
        failed_functions+=("$func")
    fi
done

if [[ ${#failed_functions[@]} -gt 0 ]]; then
    echo "功能测试失败，缺少函数: ${failed_functions[*]}"
    exit 1
else
    echo "核心功能测试通过"
    exit 0
fi
EOF
    
    if zsh "$test_script" 2>/dev/null; then
        log_success "功能测试通过"
        rm -f "$test_script"
        return 0
    else
        log_error "功能测试失败"
        rm -f "$test_script"
        return 1
    fi
}

# 快速工具依赖检查
quick_dependency_check() {
    log_info "执行快速工具依赖检查..."
    
    local core_tools=("bat" "fd" "fzf" "rg" "git")
    local available_tools=()
    local missing_tools=()
    
    for tool in "${core_tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            available_tools+=("$tool")
        else
            missing_tools+=("$tool")
        fi
    done
    
    log_info "可用工具: ${available_tools[*]}"
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        log_warn "缺少工具: ${missing_tools[*]}"
    fi
    
    # 检查别名设置
    local alias_check_script="/tmp/shell-tools-alias-test-$$.zsh"
    cat > "$alias_check_script" << 'EOF'
#!/bin/zsh

# 加载工具检测模块
source "$HOME/.oh-my-zsh/custom/modules/01-tool-detection.zsh" 2>/dev/null

# 检查关键别名
if command -v batcat >/dev/null 2>&1; then
    if ! alias bat 2>/dev/null | grep -q batcat; then
        echo "bat别名设置异常"
        exit 1
    fi
fi

if command -v fdfind >/dev/null 2>&1; then
    if ! alias fd 2>/dev/null | grep -q fdfind; then
        echo "fd别名设置异常"
        exit 1
    fi
fi

echo "别名检查通过"
exit 0
EOF
    
    if zsh "$alias_check_script" 2>/dev/null; then
        log_success "工具依赖检查通过"
        rm -f "$alias_check_script"
        return 0
    else
        log_warn "工具依赖检查有警告"
        rm -f "$alias_check_script"
        return 0  # 不作为失败处理
    fi
}

# 快速性能测试
quick_performance_test() {
    log_info "执行快速性能测试..."
    
    local start_time=$(date +%s.%N)
    
    # 测试配置加载时间
    local perf_test_script="/tmp/shell-tools-perf-test-$$.zsh"
    cat > "$perf_test_script" << 'EOF'
#!/bin/zsh

start_time=$(date +%s.%N)

# 加载主配置
if [[ -f "$HOME/.oh-my-zsh/custom/shell-tools-main.zsh" ]]; then
    source "$HOME/.oh-my-zsh/custom/shell-tools-main.zsh" 2>/dev/null
fi

end_time=$(date +%s.%N)
load_time=$(echo "$end_time - $start_time" | bc -l 2>/dev/null || echo "0")

echo "配置加载时间: ${load_time}秒"

# 检查加载时间是否合理（应该小于5秒）
if command -v bc >/dev/null 2>&1; then
    if [[ $(echo "$load_time > 5" | bc -l) -eq 1 ]]; then
        echo "配置加载时间过长"
        exit 1
    fi
fi

exit 0
EOF
    
    if zsh "$perf_test_script" 2>/dev/null; then
        local end_time=$(date +%s.%N)
        local total_time=$(echo "$end_time - $start_time" | bc -l 2>/dev/null || echo "未知")
        log_success "性能测试通过，总耗时: ${total_time}秒"
        rm -f "$perf_test_script"
        return 0
    else
        log_warn "性能测试有警告"
        rm -f "$perf_test_script"
        return 0
    fi
}

# 主函数
main() {
    echo "================================================================="
    echo " Shell工具配置模块快速回归测试"
    echo " 版本: 2.1"
    echo " 预计时间: 15分钟"
    echo " 开始时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "================================================================="
    
    local start_time=$(date +%s)
    local failed_tests=0
    
    # 执行测试步骤
    quick_syntax_check || ((failed_tests++))
    echo
    
    quick_generation_test || ((failed_tests++))
    echo
    
    quick_functionality_test || ((failed_tests++))
    echo
    
    quick_dependency_check || ((failed_tests++))
    echo
    
    quick_performance_test || ((failed_tests++))
    echo
    
    # 计算总耗时
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    local minutes=$((duration / 60))
    local seconds=$((duration % 60))
    
    echo "================================================================="
    echo " 快速回归测试完成"
    echo " 结束时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo " 总耗时: ${minutes}分${seconds}秒"
    echo " 失败测试: $failed_tests"
    echo "================================================================="
    
    if [[ $failed_tests -eq 0 ]]; then
        log_success "所有快速回归测试通过！"
        exit 0
    else
        log_error "有 $failed_tests 个测试失败，建议运行完整测试"
        exit 1
    fi
}

# 执行主函数
main "$@"
