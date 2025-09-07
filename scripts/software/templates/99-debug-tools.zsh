# =============================================================================
# Shell Tools Debug Module - 调试和诊断功能
# =============================================================================

# 增强的调试函数：检查工具安装状态和模块加载情况
shell-tools-debug() {
    echo "=== Shell Tools Debug Information ==="
    echo "版本: 2.1 (模块化重构版 - 基于模板)"
    echo "配置目录: $HOME/.oh-my-zsh/custom/"
    echo
    
    echo "PATH配置:"
    echo "  PATH: $PATH"
    echo
    
    echo "工具检测:"
    echo "  bat: $(command -v bat 2>/dev/null || echo 'not found')"
    echo "  batcat: $(command -v batcat 2>/dev/null || echo 'not found')"
    echo "  fd: $(command -v fd 2>/dev/null || echo 'not found')"
    echo "  fdfind: $(command -v fdfind 2>/dev/null || echo 'not found')"
    echo "  fzf: $(command -v fzf 2>/dev/null || echo 'not found')"
    echo "  rg: $(command -v rg 2>/dev/null || echo 'not found')"
    echo "  git: $(command -v git 2>/dev/null || echo 'not found')"
    echo
    
    echo "别名状态:"
    alias | grep -E '^(bat|fd)=' || echo "  无相关别名"
    echo
    
    echo "模块加载状态:"
    if [[ -n "${!SHELL_TOOLS_MODULES_LOADED[@]}" ]]; then
        for module in "${!SHELL_TOOLS_MODULES_LOADED[@]}"; do
            echo "  ✓ $module"
        done
    else
        echo "  无已加载模块"
    fi
    
    if [[ -n "${!SHELL_TOOLS_MODULES_FAILED[@]}" ]]; then
        echo
        echo "模块加载失败:"
        for module in "${!SHELL_TOOLS_MODULES_FAILED[@]}"; do
            echo "  ✗ $module"
        done
    fi
    
    echo
    echo "配置文件状态:"
    local modules_dir="$HOME/.oh-my-zsh/custom/modules"
    if [[ -d "$modules_dir" ]]; then
        echo "  模块目录: $modules_dir"
        local module_count=$(ls -1 "$modules_dir"/*.zsh 2>/dev/null | wc -l)
        echo "  模块文件数量: $module_count"
    else
        echo "  ⚠️  模块目录不存在"
    fi
    
    echo "=========================="
}

# 模块重新加载函数
shell-tools-reload() {
    echo "重新加载 Shell Tools 模块..."
    
    # 清除加载状态
    unset SHELL_TOOLS_MODULES_LOADED
    unset SHELL_TOOLS_MODULES_FAILED
    unset SHELL_TOOLS_MAIN_LOADED
    
    # 重新加载主配置
    local main_config="$HOME/.oh-my-zsh/custom/shell-tools-main.zsh"
    if [[ -f "$main_config" ]]; then
        source "$main_config"
        echo "✓ 重新加载完成"
    else
        echo "✗ 主配置文件不存在: $main_config"
    fi
}

# 模块状态检查函数
shell-tools-status() {
    local loaded_count=${#SHELL_TOOLS_MODULES_LOADED[@]}
    local failed_count=${#SHELL_TOOLS_MODULES_FAILED[@]}
    
    echo "Shell Tools 状态:"
    echo "  已加载模块: $loaded_count"
    echo "  失败模块: $failed_count"
    
    if [[ $failed_count -gt 0 ]]; then
        echo "  建议运行 'shell-tools-debug' 查看详细信息"
    fi
}
