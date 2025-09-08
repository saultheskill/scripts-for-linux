# =============================================================================
# Shell Tools Main Configuration - 模块化配置系统
# 由 {{GENERATOR_VERSION}} 自动生成于 {{GENERATION_TIME}}
# 集成了 fzf、bat、fd、ripgrep、git 等工具的模块化配置
# =============================================================================

# 模块加载状态跟踪
declare -A SHELL_TOOLS_MODULES_LOADED
declare -A SHELL_TOOLS_MODULES_FAILED

# 模块加载函数
load_shell_tools_module() {
    local module_name="$1"
    local module_path="$2"

    if [[ -f "$module_path" ]]; then
        if source "$module_path" 2>/dev/null; then
            SHELL_TOOLS_MODULES_LOADED["$module_name"]=1
            [[ -n "$SHELL_TOOLS_DEBUG" ]] && echo "✓ 已加载模块: $module_name"
        else
            SHELL_TOOLS_MODULES_FAILED["$module_name"]=1
            [[ -n "$SHELL_TOOLS_DEBUG" ]] && echo "✗ 模块加载失败: $module_name"
        fi
    else
        [[ -n "$SHELL_TOOLS_DEBUG" ]] && echo "⚠ 模块文件不存在: $module_path"
    fi
}

# 加载所有模块
load_all_modules() {
    local modules_dir="{{MODULES_DIR}}"

    if [[ ! -d "$modules_dir" ]]; then
        echo "警告: 模块目录不存在: $modules_dir"
        return 1
    fi

    # 按数字前缀顺序加载模块
    for module_file in "$modules_dir"/*.zsh; do
        if [[ -f "$module_file" ]]; then
            local module_name=$(basename "$module_file" .zsh)
            load_shell_tools_module "$module_name" "$module_file"
        fi
    done
}

# 调试模块现在是标准模块系统的一部分（99-debug-tools.zsh）
# 通过 load_all_modules() 自动加载

# 主加载逻辑
if [[ -z "$SHELL_TOOLS_MAIN_LOADED" ]]; then
    export SHELL_TOOLS_MAIN_LOADED=1

    # 加载所有模块（包括调试模块 99-debug-tools.zsh）
    load_all_modules

    # 显示加载状态
    if [[ -z "$SHELL_TOOLS_QUIET" ]]; then
        local loaded_count=${#SHELL_TOOLS_MODULES_LOADED[@]}
        local failed_count=${#SHELL_TOOLS_MODULES_FAILED[@]}

        echo "🚀 Shell Tools 模块化配置已加载！"
        echo "📦 已加载 $loaded_count 个模块"
        if [[ $failed_count -gt 0 ]]; then
            echo "⚠️  $failed_count 个模块加载失败"
        fi
        echo "💡 运行 'show-tools' 查看所有可用功能"
        echo "🔧 运行 'shell-tools-debug' 查看详细状态"
    fi
fi
