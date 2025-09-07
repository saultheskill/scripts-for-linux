#!/usr/bin/env python3

"""
Shell工具配置生成器 - 模块化版本
作者: saul
版本: 2.0
描述: 生成模块化的现代shell工具最佳实践配置
"""

import os
import sys
from pathlib import Path
from typing import Dict, List, Tuple, Optional

# 添加scripts目录到Python路径
script_dir = Path(__file__).parent
sys.path.insert(0, str(script_dir.parent))

try:
    from common import *
except ImportError:
    print("错误：无法导入common模块")
    sys.exit(1)

# 模块化配置系统的常量定义
CUSTOM_DIR = Path.home() / ".oh-my-zsh" / "custom"
MODULES_DIR = CUSTOM_DIR / "modules"
DEBUG_DIR = CUSTOM_DIR / "debug"
MAIN_CONFIG_FILE = CUSTOM_DIR / "shell-tools-main.zsh"
OLD_CONFIG_FILE = Path.home() / ".shell-tools-config.zsh"

# 模块定义：(文件名, 描述, 依赖工具, 依赖模块)
MODULES_CONFIG = [
    ("00-path-config.zsh", "PATH和基础环境配置", [], []),
    ("01-tool-detection.zsh", "工具可用性检测和别名统一化", ["bat", "fd"], ["00-path-config"]),
    ("02-bat-config.zsh", "bat工具核心配置和基础功能", ["bat"], ["01-tool-detection"]),
    ("03-fd-config.zsh", "fd/fdfind工具配置和基础功能", ["fd"], ["01-tool-detection"]),
    ("04-fzf-core.zsh", "fzf核心配置和显示设置", ["fzf"], ["01-tool-detection"]),
    ("05-fzf-basic.zsh", "fzf基础功能（文件搜索、编辑等）", ["fzf", "bat"], ["04-fzf-core", "02-bat-config"]),
    ("06-fzf-advanced.zsh", "fzf高级功能（动态重载、模式切换等）", ["fzf", "bat", "fd"], ["05-fzf-basic", "03-fd-config"]),
    ("07-ripgrep-config.zsh", "ripgrep配置和基础集成", ["rg"], ["01-tool-detection"]),
    ("08-ripgrep-fzf.zsh", "ripgrep + fzf高级集成功能", ["rg", "fzf", "bat"], ["07-ripgrep-config", "05-fzf-basic"]),
    ("09-git-integration.zsh", "git + fzf + bat集成功能", ["git", "fzf", "bat"], ["05-fzf-basic"]),
    ("10-log-monitoring.zsh", "日志监控和tail集成功能", ["bat", "fzf"], ["02-bat-config", "04-fzf-core"]),
    ("11-man-integration.zsh", "man页面集成（修复batman搜索功能）", ["bat", "fzf"], ["02-bat-config", "04-fzf-core"]),
    ("12-apt-integration.zsh", "APT包管理集成功能", ["fzf", "bat"], ["04-fzf-core", "02-bat-config"]),
    ("13-utility-functions.zsh", "通用工具函数（search-all等）", ["bat", "fd", "rg"], ["02-bat-config", "03-fd-config", "07-ripgrep-config"]),
    ("99-aliases-summary.zsh", "最终别名汇总和show-tools功能", [], ["*"]),
]

def check_tool_availability(tool: str) -> bool:
    """检查工具是否可用"""
    import subprocess
    try:
        subprocess.run([tool, "--version"], capture_output=True, check=True)
        return True
    except (subprocess.CalledProcessError, FileNotFoundError):
        # 特殊处理一些工具
        if tool == "bat":
            try:
                subprocess.run(["batcat", "--version"], capture_output=True, check=True)
                return True
            except (subprocess.CalledProcessError, FileNotFoundError):
                pass
        elif tool == "fd":
            try:
                subprocess.run(["fdfind", "--version"], capture_output=True, check=True)
                return True
            except (subprocess.CalledProcessError, FileNotFoundError):
                pass
        return False

def create_directories():
    """创建必要的目录结构"""
    try:
        CUSTOM_DIR.mkdir(parents=True, exist_ok=True)
        MODULES_DIR.mkdir(parents=True, exist_ok=True)
        DEBUG_DIR.mkdir(parents=True, exist_ok=True)
        log_info(f"创建目录结构: {CUSTOM_DIR}")
        return True
    except Exception as e:
        log_error(f"创建目录失败: {str(e)}")
        return False

def generate_main_config():
    """生成主配置文件"""
    content = '''# =============================================================================
# Shell Tools Main Configuration - 模块化配置系统
# 由 shell-tools-config-generator.py v2.0 自动生成
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

# 检查模块依赖
check_module_dependencies() {
    local module_name="$1"
    shift
    local dependencies=("$@")

    for dep in "${dependencies[@]}"; do
        if [[ "$dep" != "*" ]] && [[ -z "${SHELL_TOOLS_MODULES_LOADED[$dep]}" ]]; then
            [[ -n "$SHELL_TOOLS_DEBUG" ]] && echo "⚠ 模块 $module_name 依赖 $dep 未加载"
            return 1
        fi
    done
    return 0
}

# 加载所有模块
load_all_modules() {
    local modules_dir="$HOME/.oh-my-zsh/custom/modules"

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

# 加载调试模块
load_debug_module() {
    local debug_file="$HOME/.oh-my-zsh/custom/debug/shell-tools-debug.zsh"
    if [[ -f "$debug_file" ]]; then
        source "$debug_file"
    fi
}

# 主加载逻辑
if [[ -z "$SHELL_TOOLS_MAIN_LOADED" ]]; then
    export SHELL_TOOLS_MAIN_LOADED=1

    # 设置调试模式（如果需要）
    # export SHELL_TOOLS_DEBUG=1

    # 加载所有模块
    load_all_modules

    # 加载调试功能
    load_debug_module

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
'''

    try:
        with open(MAIN_CONFIG_FILE, 'w') as f:
            f.write(content)
        log_success(f"主配置文件已生成: {MAIN_CONFIG_FILE}")
        return True
    except Exception as e:
        log_error(f"生成主配置文件失败: {str(e)}")
        return False

def generate_shell_tools_config():
    """
    生成模块化shell工具配置文件

    Returns:
        bool: 生成是否成功
    """
    # 创建目录结构
    if not create_directories():
        return False

    # 生成主配置文件
    if not generate_main_config():
        return False

    # 生成各个模块
    success_count = 0
    total_count = len(MODULES_CONFIG)

    for module_file, description, required_tools, dependencies in MODULES_CONFIG:
        # 检查工具可用性
        tools_available = all(check_tool_availability(tool) for tool in required_tools) if required_tools else True

        if tools_available or not required_tools:  # 如果没有依赖工具或工具都可用
            if generate_module(module_file, description, required_tools, dependencies):
                success_count += 1
            else:
                log_warn(f"模块 {module_file} 生成失败")
        else:
            log_info(f"跳过模块 {module_file}（缺少必需工具: {', '.join(required_tools)}）")

    # 生成调试模块
    if generate_debug_module():
        log_success("调试模块已生成")

    log_success(f"模块化配置生成完成！成功生成 {success_count}/{total_count} 个模块")
    return success_count > 0

def generate_module(module_file: str, description: str, required_tools: List[str], dependencies: List[str]) -> bool:
    """生成单个模块文件"""
    module_path = MODULES_DIR / module_file

    try:
        # 根据模块名称生成对应的内容
        if module_file.startswith("00-path-config"):
            content = generate_path_config_module()
        elif module_file.startswith("01-tool-detection"):
            content = generate_tool_detection_module()
        elif module_file.startswith("02-bat-config"):
            content = generate_bat_config_module()
        elif module_file.startswith("03-fd-config"):
            content = generate_fd_config_module()
        elif module_file.startswith("04-fzf-core"):
            content = generate_fzf_core_module()
        elif module_file.startswith("05-fzf-basic"):
            content = generate_fzf_basic_module()
        elif module_file.startswith("06-fzf-advanced"):
            content = generate_fzf_advanced_module()
        elif module_file.startswith("07-ripgrep-config"):
            content = generate_ripgrep_config_module()
        elif module_file.startswith("08-ripgrep-fzf"):
            content = generate_ripgrep_fzf_module()
        elif module_file.startswith("09-git-integration"):
            content = generate_git_integration_module()
        elif module_file.startswith("10-log-monitoring"):
            content = generate_log_monitoring_module()
        elif module_file.startswith("11-man-integration"):
            content = generate_man_integration_module()
        elif module_file.startswith("12-apt-integration"):
            content = generate_apt_integration_module()
        elif module_file.startswith("13-utility-functions"):
            content = generate_utility_functions_module()
        elif module_file.startswith("99-aliases-summary"):
            content = generate_aliases_summary_module()
        else:
            log_warn(f"未知模块类型: {module_file}")
            return False

        # 添加模块头部信息
        header = f'''# =============================================================================
# {description}
# 模块文件: {module_file}
# 依赖工具: {', '.join(required_tools) if required_tools else '无'}
# 依赖模块: {', '.join(dependencies) if dependencies else '无'}
# 由 shell-tools-config-generator.py v2.0 自动生成
# =============================================================================

'''

        full_content = header + content

        with open(module_path, 'w') as f:
            f.write(full_content)

        log_success(f"模块已生成: {module_file}")
        return True

    except Exception as e:
        log_error(f"生成模块 {module_file} 失败: {str(e)}")
        return False

def generate_debug_module() -> bool:
    """生成调试模块"""
    debug_path = DEBUG_DIR / "shell-tools-debug.zsh"

    content = '''# =============================================================================
# Shell Tools Debug Module - 调试和诊断功能
# =============================================================================

# 增强的调试函数：检查工具安装状态和模块加载情况
shell-tools-debug() {
    echo "=== Shell Tools Debug Information ==="
    echo "版本: 2.0 (模块化)"
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
    if [[ -n "${SHELL_TOOLS_MODULES_LOADED[@]}" ]]; then
        for module in "${!SHELL_TOOLS_MODULES_LOADED[@]}"; do
            echo "  ✓ $module"
        done
    else
        echo "  无已加载模块"
    fi

    if [[ -n "${SHELL_TOOLS_MODULES_FAILED[@]}" ]]; then
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
'''

    try:
        with open(debug_path, 'w') as f:
            f.write(content)
        return True
    except Exception as e:
        log_error(f"生成调试模块失败: {str(e)}")
        return False

def generate_path_config_module() -> str:
    """生成PATH配置模块"""
    return '''# PATH和基础环境配置 - 必须在所有工具检测之前执行

# 修复Ubuntu/Debian系统PATH问题 - 确保/bin和/usr/bin在PATH中
# 这对于fd/fdfind等工具的正确检测至关重要
if [[ ":$PATH:" != *":/bin:"* ]]; then
    export PATH="/bin:$PATH"
fi

if [[ ":$PATH:" != *":/usr/bin:"* ]]; then
    export PATH="/usr/bin:$PATH"
fi

# 确保/usr/local/bin也在PATH中（某些系统可能需要）
if [[ ":$PATH:" != *":/usr/local/bin:"* ]]; then
    export PATH="/usr/local/bin:$PATH"
fi

# 刷新命令哈希表以确保新的PATH生效
hash -r 2>/dev/null || true
'''

def generate_tool_detection_module() -> str:
    """生成工具检测模块"""
    return '''# 工具可用性检测和别名统一化

# 检测并统一 bat 命令（Ubuntu/Debian 使用 batcat）
if command -v batcat >/dev/null 2>&1; then
    alias bat='batcat'
elif command -v bat >/dev/null 2>&1; then
    # bat 已经可用，无需别名
    :
fi

# 检测并统一 fd 命令（Ubuntu/Debian 使用 fdfind）
# 优先检查fdfind，因为在Ubuntu/Debian系统上这是标准安装名称
if command -v fdfind >/dev/null 2>&1; then
    alias fd='fdfind'
    # 验证别名是否工作
    if ! fd --version >/dev/null 2>&1; then
        echo "警告：fd别名设置失败，请检查fdfind安装"
    fi
elif command -v fd >/dev/null 2>&1; then
    # fd 已经可用，无需别名
    :
else
    # 如果都没有找到，提供安装提示
    echo "提示：未找到fd工具。在Ubuntu/Debian上请运行: sudo apt install fd-find"
fi
'''

def generate_bat_config_module() -> str:
    """生成bat配置模块"""
    return '''# bat (cat的增强版) 核心配置

if command -v bat >/dev/null 2>&1 || command -v batcat >/dev/null 2>&1; then
    # bat 环境变量配置
    export BAT_STYLE="numbers,changes,header,grid"
    export BAT_THEME="OneHalfDark"
    export BAT_PAGER="less -RFK"

    # 基础别名 - 使用动态检测的bat命令
    if command -v batcat >/dev/null 2>&1; then
        alias cat='batcat --paging=never'
        alias less='batcat --paging=always'
        alias more='batcat --paging=always'
        alias batl='batcat --paging=always'  # 强制分页
        alias batn='batcat --style=plain'    # 纯文本模式，无装饰
        alias batp='batcat --plain'          # 纯文本模式（简写）
    elif command -v bat >/dev/null 2>&1; then
        alias cat='bat --paging=never'
        alias less='bat --paging=always'
        alias more='bat --paging=always'
        alias batl='bat --paging=always'  # 强制分页
        alias batn='bat --style=plain'    # 纯文本模式，无装饰
        alias batp='bat --plain'          # 纯文本模式（简写）
    fi
fi
'''

def generate_fd_config_module() -> str:
    """生成fd配置模块"""
    return '''# fd (find的现代替代品) 配置

if command -v fd >/dev/null 2>&1; then
    # 基础搜索别名
    alias fdf='fd --type f'                    # 搜索文件
    alias fdd='fd --type d'                    # 搜索目录
    alias fda='fd --hidden --no-ignore'       # 搜索所有文件（包括隐藏）
    alias fdx='fd --type f --executable'      # 搜索可执行文件
    alias fds='fd --type s'                   # 搜索符号链接

    # fd + bat 集成：批量查看搜索结果
    if command -v bat >/dev/null 2>&1 || command -v batcat >/dev/null 2>&1; then
        # 搜索并用 bat 查看所有匹配的文件
        fdbat() {
            if [[ $# -eq 0 ]]; then
                echo "用法: fdbat <搜索模式> [路径]"
                echo "示例: fdbat '\\.py$' src/"
                return 1
            fi

            # 使用动态检测的bat命令
            if command -v batcat >/dev/null 2>&1; then
                fd "$@" --type f -X batcat
            elif command -v bat >/dev/null 2>&1; then
                fd "$@" --type f -X bat
            else
                fd "$@" --type f -X cat
            fi
        }

        # 搜索并预览文件内容
        fdpreview() {
            # 确保bat命令可用
            local bat_cmd
            if command -v batcat >/dev/null 2>&1; then
                bat_cmd='batcat'
            elif command -v bat >/dev/null 2>&1; then
                bat_cmd='bat'
            else
                echo "错误：未找到bat工具，请先安装"
                return 1
            fi

            if [[ $# -eq 0 ]]; then
                echo "用法: fdpreview <搜索模式> [路径]"
                return 1
            fi
            fd "$@" --type f -x "$bat_cmd" --color=always --style=header,grid --line-range=:50
        }
    fi
fi
'''

def generate_fzf_core_module() -> str:
    """生成fzf核心配置模块"""
    return '''# fzf (模糊查找工具) 核心配置与显示设置

if command -v fzf >/dev/null 2>&1; then
    # 高级默认选项配置 - 基于官方ADVANCED.md文档优化
    export FZF_DEFAULT_OPTS="
        --height=70%
        --layout=reverse
        --info=inline
        --border=rounded
        --margin=1
        --padding=1
        --preview-window=right:60%:wrap:border-left
        --bind='ctrl-/:toggle-preview'
        --bind='ctrl-u:preview-page-up'
        --bind='ctrl-d:preview-page-down'
        --bind='ctrl-a:select-all'
        --bind='ctrl-x:deselect-all'
        --bind='ctrl-t:toggle-all'
        --bind='alt-up:preview-up'
        --bind='alt-down:preview-down'
        --bind='ctrl-s:toggle-sort'
        --bind='ctrl-r:reload(find . -type f)'
        --bind='alt-enter:print-query'
        --color='fg:#d0d0d0,bg:#121212,hl:#5f87af'
        --color='fg+:#d0d0d0,bg+:#262626,hl+:#5fd7ff'
        --color='info:#afaf87,prompt:#d7005f,pointer:#af5fff'
        --color='marker:#87ff00,spinner:#af5fff,header:#87afaf'
        --color='border:#585858,preview-bg:#121212'
    "

    # tmux 集成配置 - 基于官方ADVANCED.md的tmux popup功能
    if [[ -n "$TMUX" ]] && command -v tmux >/dev/null 2>&1; then
        # 检查tmux版本是否支持popup (需要3.3+)
        local tmux_version
        tmux_version=$(tmux -V 2>/dev/null | sed 's/tmux //' | cut -d. -f1-2)

        if command -v bc >/dev/null 2>&1 && [[ $(echo "$tmux_version >= 3.3" | bc 2>/dev/null) -eq 1 ]]; then
            # 高级tmux popup配置
            export FZF_TMUX_OPTS="-p 80%,70%"

            # tmux popup 变体函数
            fzf-tmux-center() { fzf --tmux center,80%,70% "$@"; }
            fzf-tmux-right() { fzf --tmux right,50%,70% "$@"; }
            fzf-tmux-bottom() { fzf --tmux bottom,100%,50% "$@"; }
            fzf-tmux-top() { fzf --tmux top,100%,50% "$@"; }

            # 别名
            alias fzf-popup='fzf-tmux-center'
            alias fzf-side='fzf-tmux-right'
        else
            # 降级到传统的tmux分割窗口模式
            export FZF_TMUX_OPTS="-d 70%"
        fi
    fi

    # 使用 fd 作为 fzf 的默认搜索命令（如果可用）
    if command -v fd >/dev/null 2>&1; then
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git --exclude node_modules --exclude .cache'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git --exclude node_modules --exclude .cache'
    fi

    # fzf 键绑定加载
    if [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]]; then
        source /usr/share/doc/fzf/examples/key-bindings.zsh
    elif [[ -f ~/.fzf.zsh ]]; then
        source ~/.fzf.zsh
    fi

    # fzf 自动补全
    if [[ -f /usr/share/doc/fzf/examples/completion.zsh ]]; then
        source /usr/share/doc/fzf/examples/completion.zsh
    fi
fi
'''

def generate_fzf_basic_module() -> str:
    """生成fzf基础功能模块"""
    return '''# fzf基础功能（文件搜索、编辑等）

if command -v fzf >/dev/null 2>&1; then
    # fzf + bat 集成：带语法高亮的文件预览
    if command -v bat >/dev/null 2>&1 || command -v batcat >/dev/null 2>&1; then
        # 确定bat命令并设置预览选项
        if command -v batcat >/dev/null 2>&1; then
            export FZF_CTRL_T_OPTS="--preview 'batcat --color=always --style=numbers --line-range=:500 {}'"
        else
            export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
        fi

        # 高级文件搜索和编辑
        fzf-edit() {
            # 确保bat命令可用
            local bat_cmd
            if command -v batcat >/dev/null 2>&1; then
                bat_cmd='batcat'
            elif command -v bat >/dev/null 2>&1; then
                bat_cmd='bat'
            else
                echo "错误：未找到bat工具，请先安装"
                return 1
            fi

            local file
            file=$(fzf --preview "$bat_cmd --color=always --style=numbers,changes --line-range=:500 {}" \
                      --preview-window=right:60%:wrap \
                      --bind='ctrl-/:toggle-preview,ctrl-u:preview-page-up,ctrl-d:preview-page-down')
            if [[ -n "$file" ]]; then
                ${EDITOR:-vim} "$file"
            fi
        }

        # 搜索文件内容并预览
        fzf-content() {
            # 确保bat命令可用
            local bat_cmd
            if command -v batcat >/dev/null 2>&1; then
                bat_cmd='batcat'
            elif command -v bat >/dev/null 2>&1; then
                bat_cmd='bat'
            else
                echo "错误：未找到bat工具，请先安装"
                return 1
            fi

            if command -v rg >/dev/null 2>&1; then
                rg --color=always --line-number --no-heading --smart-case "${*:-}" |
                fzf --ansi \
                    --color "hl:-1:underline,hl+:-1:underline:reverse" \
                    --delimiter : \
                    --preview "$bat_cmd --color=always {1} --highlight-line {2}" \
                    --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
                    --bind 'enter:become(vim {1} +{2})'
            else
                echo "需要安装 ripgrep (rg) 来使用此功能"
            fi
        }

        # 查看 bat 主题预览
        fzf-bat-themes() {
            # 确保bat命令可用
            local bat_cmd
            if command -v batcat >/dev/null 2>&1; then
                bat_cmd='batcat'
            elif command -v bat >/dev/null 2>&1; then
                bat_cmd='bat'
            else
                echo "错误：未找到bat工具，请先安装"
                return 1
            fi

            $bat_cmd --list-themes | fzf --preview="$bat_cmd --theme={} --color=always ~/.bashrc || $bat_cmd --theme={} --color=always /etc/passwd"
        }
    fi

    # fzf + fd 集成：目录导航
    if command -v fd >/dev/null 2>&1; then
        fzf-cd() {
            local dir
            dir=$(fd --type d --hidden --follow --exclude .git |
                  fzf --preview 'tree -C {} | head -200' \
                      --preview-window=right:50%:wrap)
            if [[ -n "$dir" ]]; then
                cd "$dir"
            fi
        }

        # 快速跳转到项目目录
        fzf-project() {
            local project_dirs=("$HOME/projects" "$HOME/work" "$HOME/dev" "$HOME/src")
            local dir
            dir=$(fd --type d --max-depth 3 . "${project_dirs[@]}" 2>/dev/null |
                  fzf --preview 'ls -la {} | head -20' \
                      --preview-window=right:50%:wrap)
            if [[ -n "$dir" ]]; then
                cd "$dir"
            fi
        }
    fi

    # 基于fzf-basic-example.md的文件操作增强功能
    # 文件打开功能 - 基于basic example的fe函数
    fe() {
        local files
        IFS=$'\n' files=($(fzf-tmux --query="$1" --multi --select-1 --exit-0))
        [[ -n "$files" ]] && ${EDITOR:-vim} "${files[@]}"
    }

    # 文件打开（使用默认应用） - 基于basic example的fo函数
    fo() {
        local files
        IFS=$'\n' files=($(fzf-tmux --query="$1" --multi --select-1 --exit-0))
        [[ -n "$files" ]] && open "${files[@]}" 2>/dev/null || xdg-open "${files[@]}" 2>/dev/null
    }

    # 查看文件 - 基于basic example的vf函数
    vf() {
        # 确保bat命令可用
        local bat_cmd
        if command -v batcat >/dev/null 2>&1; then
            bat_cmd='batcat'
        elif command -v bat >/dev/null 2>&1; then
            bat_cmd='bat'
        else
            echo "错误：未找到bat工具，请先安装"
            return 1
        fi

        fzf --preview "$bat_cmd --color=always --style=numbers --line-range=:500 {}" | xargs -r "$bat_cmd" --paging=always
    }

    # 目录切换功能 - 基于basic example的fd函数（重命名为fdir避免冲突）
    fdir() {
        local dir
        dir=$(find ${1:-.} -path '*/\.*' -prune -o -type d -print 2> /dev/null | fzf +m) &&
        cd "$dir"
    }

    # 包含隐藏目录的切换 - 基于basic example的fda函数（重命名为fdira）
    fdira() {
        local dir
        dir=$(find ${1:-.} -type d 2> /dev/null | fzf +m) && cd "$dir"
    }

    # 树形目录切换 - 基于basic example的fdr函数（重命名为fdirt）
    fdirt() {
        local dir
        dir=$(find ${1:-.} -type d 2> /dev/null | fzf +m --preview 'tree -C {} | head -200') && cd "$dir"
    }

    # 实用别名 - 保持现有别名并添加新的
    alias fe-old='fzf-edit'       # 保持旧版本
    alias fcd='fzf-cd'            # 搜索并切换目录
    alias fp='fzf-project'        # 快速跳转项目
    alias fc='fzf-content'        # 搜索文件内容
    alias fthemes='fzf-bat-themes' # 预览 bat 主题
fi
'''

def generate_fzf_advanced_module() -> str:
    """生成fzf高级功能模块"""
    return '''# fzf高级功能（动态重载、模式切换等）

if command -v fzf >/dev/null 2>&1; then
    # 基于官方ADVANCED.md的动态重载和进程管理功能
    # 动态进程管理器 - 基于文档示例
    fzf-processes() {
        (date; ps -ef) |
        fzf --bind='ctrl-r:reload(date; ps -ef)' \
            --header=$'Press CTRL-R to reload\n\n' --header-lines=2 \
            --preview='echo {}' --preview-window=down,3,wrap \
            --layout=reverse --height=80% | awk '{print $2}' | xargs kill -9
    }

    # 动态数据源切换 - 基于文档示例
    fzf-files-dirs() {
        find * 2>/dev/null | fzf --prompt 'All> ' \
                     --header 'CTRL-D: Directories / CTRL-F: Files' \
                     --bind 'ctrl-d:change-prompt(Directories> )+reload(find * -type d 2>/dev/null)' \
                     --bind 'ctrl-f:change-prompt(Files> )+reload(find * -type f 2>/dev/null)'
    }

    # 单键切换模式 - 基于文档的transform示例
    fzf-toggle-mode() {
        # 确保bat命令可用
        local bat_cmd
        if command -v batcat >/dev/null 2>&1; then
            bat_cmd='batcat'
        elif command -v bat >/dev/null 2>&1; then
            bat_cmd='bat'
        else
            echo "错误：未找到bat工具，请先安装"
            return 1
        fi

        if command -v fd >/dev/null 2>&1; then
            fd --type file |
            fzf --prompt 'Files> ' \
                --header 'CTRL-T: Switch between Files/Directories' \
                --bind 'ctrl-t:transform:[[ ! $FZF_PROMPT =~ Files ]] &&
                        echo "change-prompt(Files> )+reload(fd --type file)" ||
                        echo "change-prompt(Directories> )+reload(fd --type directory)"' \
                --preview "[[ \$FZF_PROMPT =~ Files ]] && $bat_cmd --color=always {} || tree -C {}"
        else
            find . -type f |
            fzf --prompt 'Files> ' \
                --header 'CTRL-T: Switch between Files/Directories' \
                --bind 'ctrl-t:transform:[[ ! $FZF_PROMPT =~ Files ]] &&
                        echo "change-prompt(Files> )+reload(find . -type f)" ||
                        echo "change-prompt(Directories> )+reload(find . -type d)"'
        fi
    }

    # 基于fzf-basic-example.md的历史命令和进程管理功能
    # 历史命令重复执行 - 基于basic example的fh函数
    fh() {
        print -z $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed -E 's/ *[0-9]*\\*? *//' | sed -E 's/\\\\/\\\\\\\\/g')
    }

    # 进程终止 - 基于basic example的fkill函数
    fkill() {
        local pid
        if [ "$UID" != "0" ]; then
            pid=$(ps -f -u $UID | sed 1d | fzf -m | awk '{print $2}')
        else
            pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
        fi

        if [ "x$pid" != "x" ]
        then
            echo $pid | xargs kill -${1:-9}
        fi
    }

    # 内容搜索 - 基于basic example的fif函数（find in file）
    fif() {
        if [ ! "$#" -gt 0 ]; then echo "Need a string to search for!"; return 1; fi
        rg --files-with-matches --no-messages "$1" | fzf --preview "highlight -O ansi -l {} 2> /dev/null | rg --colors 'match:bg:yellow' --ignore-case --pretty --context 10 '$1' || rg --ignore-case --pretty --context 10 '$1' {}"
    }

    # 内容搜索并编辑 - 基于basic example的vg函数（vim grep）
    vg() {
        # 确保bat命令可用
        local bat_cmd
        if command -v batcat >/dev/null 2>&1; then
            bat_cmd='batcat'
        elif command -v bat >/dev/null 2>&1; then
            bat_cmd='bat'
        else
            echo "错误：未找到bat工具，请先安装"
            return 1
        fi

        local file
        local line

        read -r file line <<<"$(rg --no-heading --line-number $@ | fzf -0 -1 | awk -F: '{print $1, $2}')"

        if [[ -n $file ]]
        then
            ${EDITOR:-vim} $file +$line
        fi
    }

    # tmux集成功能
    if command -v tmux >/dev/null 2>&1; then
        # tmux会话管理 - 基于basic example的tm函数
        tm() {
            [[ -n "$TMUX" ]] && change="switch-client" || change="attach-session"
            if [ $1 ]; then
                tmux $change -t "$1" 2>/dev/null || (tmux new-session -d -s $1 && tmux $change -t "$1"); return
            fi
            session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --exit-0) &&  tmux $change -t "$session" || echo "No sessions found."
        }

        # tmux会话切换 - 基于basic example的fs函数
        fs() {
            local session
            session=$(tmux list-sessions -F "#{session_name}" | \
                fzf --query="$1" --select-1 --exit-0) &&
            tmux switch-client -t "$session"
        }

        # tmux窗格切换 - 基于basic example的ftpane函数
        ftpane() {
            local panes current_window current_pane target target_window target_pane
            panes=$(tmux list-panes -s -F '#I:#P - #{pane_current_path} #{pane_current_command}')
            current_pane=$(tmux display-message -p '#I:#P')
            current_window=$(tmux display-message -p '#I')

            target=$(echo "$panes" | grep -v "$current_pane" | fzf +m --reverse) || return

            target_window=$(echo $target | awk 'BEGIN{FS=":|-"} {print$1}')
            target_pane=$(echo $target | awk 'BEGIN{FS=":|-"} {print$2}' | cut -c 1)

            if [[ $current_window -eq $target_window ]]; then
                tmux select-pane -t ${target_window}.${target_pane}
            else
                tmux select-pane -t ${target_window}.${target_pane} &&
                tmux select-window -t $target_window
            fi
        }

        # tmux别名
        alias tmux-session='tm'       # tmux会话管理
        alias tmux-switch='fs'        # 会话切换
        alias tmux-pane='ftpane'      # 窗格切换
    fi

    # 高级功能别名
    alias fps='fzf-processes'     # 动态进程管理
    alias ffd='fzf-files-dirs'    # 文件目录切换
    alias ftm='fzf-toggle-mode'   # 单键模式切换
    alias fhist='fh'              # 历史命令搜索
    alias fkill-proc='fkill'      # 进程终止
    alias find-in-files='fif'     # 文件内容搜索
    alias vim-grep='vg'           # 搜索并编辑
    alias fdir-basic='fdir'       # 基础目录切换
    alias fdira-all='fdira'       # 包含隐藏目录
    alias fdirt-tree='fdirt'      # 树形预览目录
fi
'''

def generate_ripgrep_config_module() -> str:
    """生成ripgrep配置模块"""
    return '''# ripgrep配置和基础集成

if command -v rg >/dev/null 2>&1; then
    # ripgrep 基础配置
    export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"

    # 创建 ripgrep 配置文件（如果不存在）
    if [[ ! -f "$RIPGREP_CONFIG_PATH" ]]; then
        cat > "$RIPGREP_CONFIG_PATH" << 'EOF'
# 默认搜索选项
--smart-case
--follow
--hidden
--glob=!.git/*
--glob=!node_modules/*
--glob=!.vscode/*
--glob=!*.lock
EOF
    fi

    # 实用别名
    alias rgg='rg --group --color=always'
    alias rgf='rg --files-with-matches'
    alias rgl='rg --files-without-match'
fi
'''

def generate_ripgrep_fzf_module() -> str:
    """生成ripgrep+fzf集成模块"""
    return '''# ripgrep + fzf高级集成功能

if command -v rg >/dev/null 2>&1 && command -v fzf >/dev/null 2>&1; then
    if command -v bat >/dev/null 2>&1 || command -v batcat >/dev/null 2>&1; then
        # 1. 使用fzf作为Ripgrep的二级过滤器 - 基于文档示例
        rfv() {
            # 确保bat命令可用
            local bat_cmd
            if command -v batcat >/dev/null 2>&1; then
                bat_cmd='batcat'
            elif command -v bat >/dev/null 2>&1; then
                bat_cmd='bat'
            else
                echo "错误：未找到bat工具，请先安装"
                return 1
            fi

            if [[ $# -eq 0 ]]; then
                echo "用法: rfv <搜索模式>"
                echo "功能: 使用Ripgrep搜索，然后用fzf交互式过滤"
                return 1
            fi

            rg --color=always --line-number --no-heading --smart-case "${*:-}" |
            fzf --ansi \
                --color "hl:-1:underline,hl+:-1:underline:reverse" \
                --delimiter : \
                --preview "$bat_cmd --color=always {1} --highlight-line {2}" \
                --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
                --bind 'enter:become(vim {1} +{2})'
        }

        # 2. 交互式Ripgrep启动器 - 基于文档示例
        rgi() {
            # 确保bat命令可用
            local bat_cmd
            if command -v batcat >/dev/null 2>&1; then
                bat_cmd='batcat'
            elif command -v bat >/dev/null 2>&1; then
                bat_cmd='bat'
            else
                echo "错误：未找到bat工具，请先安装"
                return 1
            fi

            local RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case "
            local INITIAL_QUERY="${*:-}"
            fzf --ansi --disabled --query "$INITIAL_QUERY" \
                --bind "start:reload:$RG_PREFIX {q}" \
                --bind "change:reload:sleep 0.1; $RG_PREFIX {q} || true" \
                --delimiter : \
                --preview "$bat_cmd --color=always {1} --highlight-line {2}" \
                --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
                --bind 'enter:become(vim {1} +{2})'
        }

        # 3. 双阶段搜索：Ripgrep + fzf切换 - 基于文档示例
        rg2() {
            # 确保bat命令可用
            local bat_cmd
            if command -v batcat >/dev/null 2>&1; then
                bat_cmd='batcat'
            elif command -v bat >/dev/null 2>&1; then
                bat_cmd='bat'
            else
                echo "错误：未找到bat工具，请先安装"
                return 1
            fi

            local RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case "
            local INITIAL_QUERY="${*:-}"
            fzf --ansi --disabled --query "$INITIAL_QUERY" \
                --bind "start:reload:$RG_PREFIX {q}" \
                --bind "change:reload:sleep 0.1; $RG_PREFIX {q} || true" \
                --bind "alt-enter:unbind(change,alt-enter)+change-prompt(2. fzf> )+enable-search+clear-query" \
                --color "hl:-1:underline,hl+:-1:underline:reverse" \
                --prompt '1. ripgrep> ' \
                --delimiter : \
                --preview "$bat_cmd --color=always {1} --highlight-line {2}" \
                --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
                --bind 'enter:become(vim {1} +{2})'
        }

        # 传统batgrep功能保持兼容
        batgrep() {
            # 确保bat命令可用
            local bat_cmd
            if command -v batcat >/dev/null 2>&1; then
                bat_cmd='batcat'
            elif command -v bat >/dev/null 2>&1; then
                bat_cmd='bat'
            else
                echo "错误：未找到bat工具，请先安装"
                return 1
            fi

            if [[ $# -eq 0 ]]; then
                echo "用法: batgrep <搜索模式> [路径]"
                echo "示例: batgrep 'function' src/"
                return 1
            fi

            local pattern="$1"
            shift
            rg --color=always --line-number --no-heading --smart-case "$pattern" "$@" |
            while IFS=: read -r file line content; do
                echo "==> $file:$line <=="
                "$bat_cmd" --color=always --highlight-line="$line" --line-range="$((line-3)):$((line+3))" "$file" 2>/dev/null || echo "$content"
                echo
            done
        }

        # 交互式搜索：搜索后可以选择文件查看
        rg-fzf() {
            # 确保bat命令可用
            local bat_cmd
            if command -v batcat >/dev/null 2>&1; then
                bat_cmd='batcat'
            elif command -v bat >/dev/null 2>&1; then
                bat_cmd='bat'
            else
                echo "错误：未找到bat工具，请先安装"
                return 1
            fi

            if [[ $# -eq 0 ]]; then
                echo "用法: rg-fzf <搜索模式>"
                return 1
            fi

            rg --color=always --line-number --no-heading --smart-case "$@" |
            fzf --ansi \
                --color "hl:-1:underline,hl+:-1:underline:reverse" \
                --delimiter : \
                --preview "$bat_cmd --color=always {1} --highlight-line {2} --line-range {2}:" \
                --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
                --bind "enter:become($bat_cmd --paging=always {1} --highlight-line {2})"
        }
    fi
fi
'''

def generate_git_integration_module() -> str:
    """生成git集成模块"""
    return '''# git + fzf + bat集成功能

if command -v git >/dev/null 2>&1 && command -v fzf >/dev/null 2>&1; then
    if command -v bat >/dev/null 2>&1 || command -v batcat >/dev/null 2>&1; then
        # git show 与 bat 集成
        git-show-bat() {
            if [[ $# -eq 0 ]]; then
                echo "用法: git-show-bat <commit>:<file>"
                echo "示例: git-show-bat HEAD~1:src/main.py"
                echo "示例: git-show-bat v1.0.0:README.md"
                return 1
            fi

            local ref_file="$1"
            local file_ext="${ref_file##*.}"

            # 使用动态检测的bat命令
            if command -v batcat >/dev/null 2>&1; then
                git show "$ref_file" | batcat -l "$file_ext"
            elif command -v bat >/dev/null 2>&1; then
                git show "$ref_file" | bat -l "$file_ext"
            else
                git show "$ref_file"
            fi
        }

        # git diff 与 bat 集成：batdiff 功能
        batdiff() {
            # 使用动态检测的bat命令
            local bat_cmd
            if command -v batcat >/dev/null 2>&1; then
                bat_cmd='batcat'
            elif command -v bat >/dev/null 2>&1; then
                bat_cmd='bat'
            else
                git diff "$@"
                return
            fi

            git diff --name-only --relative --diff-filter=d "$@" |
            while read -r file; do
                echo "==> $file <=="
                git diff "$@" -- "$file" | "$bat_cmd" --language=diff
                echo
            done
        }

        # 增强的 git log 查看
        git-log-bat() {
            # 使用动态检测的bat命令
            local bat_cmd
            if command -v batcat >/dev/null 2>&1; then
                bat_cmd='batcat'
            elif command -v bat >/dev/null 2>&1; then
                bat_cmd='bat'
            else
                git log --oneline --color=always "$@" | fzf --ansi
                return
            fi

            git log --oneline --color=always "$@" |
            fzf --ansi --preview "git show --color=always {1} | $bat_cmd --language=diff" \
                --preview-window=right:60%:wrap \
                --bind "enter:become(git show {1} | $bat_cmd --language=diff --paging=always)"
        }

        # Git别名 - 包含新的交互功能
        alias gshow='git-show-bat'
        alias gdiff='batdiff'
        alias glog='git-log-bat'
    fi
fi
'''

def generate_log_monitoring_module() -> str:
    """生成日志监控模块"""
    return '''# 日志监控和tail集成功能

if command -v bat >/dev/null 2>&1 || command -v batcat >/dev/null 2>&1; then
    # tail -f 与 bat 集成：实时日志监控
    tailbat() {
        if [[ $# -eq 0 ]]; then
            echo "用法: tailbat <日志文件> [语法类型]"
            echo "示例: tailbat /var/log/syslog log"
            echo "示例: tailbat /var/log/nginx/access.log"
            return 1
        fi

        local file="$1"
        local syntax="${2:-log}"

        if [[ ! -f "$file" ]]; then
            echo "错误: 文件 '$file' 不存在"
            return 1
        fi

        # 使用动态检测的bat命令
        if command -v batcat >/dev/null 2>&1; then
            tail -f "$file" | batcat --paging=never -l "$syntax"
        elif command -v bat >/dev/null 2>&1; then
            tail -f "$file" | bat --paging=never -l "$syntax"
        else
            tail -f "$file"
        fi
    }

    # 常用日志监控别名 - 使用动态检测的bat命令
    alias tailsys='tailbat /var/log/syslog log'
    alias tailauth='tailbat /var/log/auth.log log'

    # dmesg别名需要动态检测
    if command -v batcat >/dev/null 2>&1; then
        alias taildmesg='dmesg -w | batcat --paging=never -l log'
    elif command -v bat >/dev/null 2>&1; then
        alias taildmesg='dmesg -w | bat --paging=never -l log'
    else
        alias taildmesg='dmesg -w'
    fi

    if command -v fzf >/dev/null 2>&1; then
        # 交互式日志文件选择和监控
        fzf-log-tail() {
            # 确保bat命令可用
            local bat_cmd
            if command -v batcat >/dev/null 2>&1; then
                bat_cmd='batcat'
            elif command -v bat >/dev/null 2>&1; then
                bat_cmd='bat'
            else
                echo "错误：未找到bat工具，请先安装"
                return 1
            fi

            local log_dirs=("/var/log" "/var/log/nginx" "/var/log/apache2" "$HOME/.local/share/logs")
            local log_files

            # 收集所有日志文件
            log_files=$(find "${log_dirs[@]}" -name "*.log" -o -name "syslog*" -o -name "auth.log*" -o -name "kern.log*" 2>/dev/null | sort)

            if [[ -z "$log_files" ]]; then
                echo "未找到日志文件"
                return 1
            fi

            echo "$log_files" |
            fzf --preview "tail -50 {} | $bat_cmd --color=always -l log" \
                --preview-window 'right:60%:wrap' \
                --header 'CTRL-T: Tail -f | CTRL-L: Less | Enter: View last 100 lines' \
                --bind "ctrl-t:execute(tail -f {} | $bat_cmd --paging=never -l log)" \
                --bind "ctrl-l:execute($bat_cmd --paging=always -l log {})" \
                --bind "enter:execute(tail -100 {} | $bat_cmd --paging=always -l log)"
        }

        alias flog='fzf-log-tail'          # 交互式日志选择
    fi
fi
'''

def generate_man_integration_module() -> str:
    """生成man页面集成模块（修复batman搜索功能）"""
    return '''# man页面集成（修复batman搜索功能）

if command -v bat >/dev/null 2>&1 || command -v batcat >/dev/null 2>&1; then
    # 设置 MANPAGER 使用 bat 作为 man 页面的分页器 - 修复兼容性
    if command -v batcat >/dev/null 2>&1; then
        export MANPAGER="sh -c 'col -bx | batcat -l man -p'"
    elif command -v bat >/dev/null 2>&1; then
        export MANPAGER="sh -c 'col -bx | bat -l man -p'"
    fi

    # 基于fzf-basic-example.md的高级man页面功能
    # 简单的man页面搜索 - 基于basic example
    fman() {
        if command -v fzf >/dev/null 2>&1; then
            man -k . | fzf -q "$1" --prompt='man> ' --preview 'echo {} | tr -d "()" | awk "{printf \"%s \", \$2} {print \$1}" | xargs -r man' | tr -d '()' | awk '{printf "%s ", $2} {print $1}' | xargs -r man
        else
            echo "用法: fman <关键词>"
            echo "需要安装 fzf 来使用此功能"
            apropos "$@"
        fi
    }

    # 高级man页面widget - 修复搜索和主题问题
    batman() {
        if command -v fzf >/dev/null 2>&1; then
            # 确保bat命令可用
            local bat_cmd
            if command -v batcat >/dev/null 2>&1; then
                bat_cmd='batcat'
            elif command -v bat >/dev/null 2>&1; then
                bat_cmd='bat'
            else
                echo "错误：未找到bat工具，请先安装"
                return 1
            fi

            # 修复：简化预览命令，避免复杂的转义和语法错误
            # 修复：使用更简单的man页面解析
            man -k . 2>/dev/null | \
            awk '{
                # 提取命令名（去掉括号内容）
                cmd = $1
                gsub(/\([^)]*\)/, "", cmd)
                # 提取描述
                desc = ""
                for(i=2; i<=NF; i++) desc = desc " " $i
                printf "%-20s %s\n", cmd, desc
            }' | \
            sort | \
            fzf \
                --query="$1" \
                --ansi \
                --tiebreak=begin \
                --prompt=' Man > ' \
                --preview-window '50%,rounded,<50(up,85%,border-bottom)' \
                --preview "echo {} | awk '{print \$1}' | xargs -I {} sh -c 'man {} 2>/dev/null | col -bx | $bat_cmd --language=man --plain --color=always --theme=OneHalfDark || echo \"Manual not found for {}\"'" \
                --bind "enter:execute(echo {} | awk '{print \$1}' | xargs -r man)" \
                --bind "alt-c:+change-preview(echo {} | awk '{print \$1}' | xargs -I {} sh -c 'curl -s cht.sh/{} 2>/dev/null || echo \"cheat.sh not available for {}\"')+change-prompt(' Cheat > ')" \
                --bind "alt-t:+change-preview(echo {} | awk '{print \$1}' | xargs -I {} sh -c 'tldr --color=always {} 2>/dev/null || echo \"tldr not available for {}\"')+change-prompt(' TLDR > ')" \
                --header 'ENTER: Open man page | ALT-C: Cheat.sh | ALT-T: TLDR'
        else
            # 降级到简单版本（如果没有fzf）
            if [[ $# -eq 0 ]]; then
                echo "用法: batman <命令名>"
                return 1
            fi

            # 使用动态检测的bat命令
            if command -v batcat >/dev/null 2>&1; then
                man "$@" | batcat -p -lman
            elif command -v bat >/dev/null 2>&1; then
                man "$@" | bat -p -lman
            else
                man "$@"
            fi
        fi
    }

    # man页面搜索函数
    man-search() {
        if [[ $# -eq 0 ]]; then
            echo "用法: man-search <关键词>"
            return 1
        fi
        if command -v fzf >/dev/null 2>&1; then
            fman "$@"
        else
            apropos "$@"
        fi
    }
fi
'''

def generate_apt_integration_module() -> str:
    """生成APT集成模块"""
    return '''# APT包管理集成功能

if command -v apt-cache >/dev/null 2>&1 && command -v fzf >/dev/null 2>&1 && command -v xargs >/dev/null 2>&1; then
    # 交互式APT软件包搜索和安装 - 主要功能
    alias af='apt-cache search "" | sort | cut --delimiter " " --fields 1 | fzf --multi --cycle --reverse --preview-window=right:70%:wrap --preview "apt-cache show {1}" | xargs -r sudo apt install -y'

    # APT软件包搜索（仅搜索，不安装）
    apt-search() {
        if [[ $# -eq 0 ]]; then
            echo "用法: apt-search [搜索词]"
            echo "功能: 交互式搜索APT软件包（不安装）"
            echo "示例: apt-search python"
            return 1
        fi

        # 修复：正确传递搜索参数给apt-cache search
        apt-cache search "$*" | sort |
        fzf --multi --cycle --reverse \
            --query="$*" \
            --preview-window=right:70%:wrap \
            --preview "apt-cache show {1}" \
            --header "搜索: $* | TAB: 多选 | ENTER: 查看详情 | ESC: 退出" |
        cut --delimiter " " --fields 1
    }

    # APT已安装软件包管理
    apt-installed() {
        dpkg --get-selections | grep -v deinstall | cut -f1 |
        fzf --multi --cycle --reverse \
            --preview-window=right:70%:wrap \
            --preview "apt-cache show {1}" \
            --header "已安装的软件包 | TAB: 多选 | ENTER: 查看详情"
    }

    # APT软件包信息查看
    apt-info() {
        if [[ $# -eq 0 ]]; then
            echo "用法: apt-info <软件包名>"
            echo "功能: 查看软件包详细信息"
            return 1
        fi

        # 确保bat命令可用
        local bat_cmd
        if command -v batcat >/dev/null 2>&1; then
            bat_cmd='batcat'
        elif command -v bat >/dev/null 2>&1; then
            bat_cmd='bat'
        else
            apt-cache show "$1"
            return
        fi

        apt-cache show "$1" | "$bat_cmd" -l yaml --paging=always
    }

    # APT别名
    alias as='apt-search'        # APT搜索
    alias ai='apt-installed'     # 已安装软件包
    alias ainfo='apt-info'       # 软件包信息
fi
'''

def generate_utility_functions_module() -> str:
    """生成通用工具函数模块"""
    return '''# 通用工具函数（search-all等）

# 综合搜索函数：结合 fd、rg、fzf、bat
search-all() {
    if [[ $# -eq 0 ]]; then
        echo "用法: search-all <搜索模式> [路径]"
        echo "功能: 同时搜索文件名和文件内容"
        return 1
    fi

    # 确保bat命令可用
    local bat_cmd
    if command -v batcat >/dev/null 2>&1; then
        bat_cmd='batcat'
    elif command -v bat >/dev/null 2>&1; then
        bat_cmd='bat'
    else
        echo "错误：未找到bat工具，请先安装"
        return 1
    fi

    local pattern="$1"
    local path="${2:-.}"

    echo "==> 搜索文件名包含 '$pattern' 的文件 <=="
    # 检查fd或fdfind是否可用，优先使用fd（可能是别名）
    if command -v fd >/dev/null 2>&1 || command -v fdfind >/dev/null 2>&1; then
        # 尝试使用fd，如果失败则使用fdfind
        if ! fd "$pattern" "$path" --type f -x "$bat_cmd" --color=always --style=header --line-range=:10 2>/dev/null; then
            if command -v fdfind >/dev/null 2>&1; then
                fdfind "$pattern" "$path" --type f -x "$bat_cmd" --color=always --style=header --line-range=:10
            fi
        fi
    else
        echo "提示：未找到fd工具，跳过文件名搜索"
    fi

    echo -e "\n==> 搜索文件内容包含 '$pattern' 的文件 <=="
    if command -v rg >/dev/null 2>&1; then
        rg --color=always --line-number --no-heading "$pattern" "$path" | head -20
    else
        echo "提示：未找到ripgrep工具，跳过文件内容搜索"
    fi
}

# 项目分析函数：分析代码项目结构
project-analyze() {
    local dir="${1:-.}"

    echo "==> 项目结构分析: $dir <=="

    # 文件类型统计
    if command -v fd >/dev/null 2>&1; then
        echo -e "\n文件类型统计:"
        fd --type f . "$dir" | sed 's/.*\.//' | sort | uniq -c | sort -nr | head -10
    fi

    # 最大的文件
    echo -e "\n最大的文件:"
    find "$dir" -type f -exec ls -lh {} + | sort -k5 -hr | head -5 | awk '{print $9 ": " $5}'
}

# 快速查找大文件（增强版）
find-large-files() {
    local size=${1:-100M}
    local path="${2:-.}"

    echo "查找大于 $size 的文件..."
    find "$path" -type f -size +$size -exec ls -lh {} + | sort -k5 -hr
}

# 查找最近修改的文件
find-recent() {
    local days=${1:-7}
    local path="${2:-.}"

    echo "查找最近 $days 天修改的文件..."
    find "$path" -type f -mtime -$days -exec ls -lht {} + | head -20
}

# 端口占用检查
port-check() {
    local port=${1:-80}
    echo "检查端口 $port 的占用情况..."

    if command -v ss >/dev/null 2>&1; then
        ss -tulpn | grep ":$port"
    elif command -v netstat >/dev/null 2>&1; then
        netstat -tulpn | grep ":$port"
    else
        echo "需要安装 ss 或 netstat 工具"
    fi
}

# 系统信息概览
sysinfo() {
    echo "=== 系统信息概览 ==="
    echo "主机名: $(hostname)"
    echo "内核: $(uname -r)"
    echo "发行版: $(lsb_release -d 2>/dev/null | cut -f2 || echo 'Unknown')"
    echo "CPU: $(nproc) 核心"
    echo "内存: $(free -h | awk '/^Mem:/ {print $2}')"
    echo "磁盘: $(df -h / | awk 'NR==2 {print $2 " (已用 " $3 ")"}')"
    echo "负载: $(uptime | awk -F'load average:' '{print $2}')"
}
'''

def generate_aliases_summary_module() -> str:
    """生成别名汇总和show-tools功能模块"""
    return '''# 最终别名汇总和show-tools功能

# 综合别名和快捷键配置
# 文件和目录操作增强
alias ll='ls -alF --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# 安全操作别名
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# 网络和系统工具别名
alias ping='ping -c 5'
alias wget='wget -c'
alias df='df -h'
alias free='free -h'
alias ps='ps aux'

# 开发工具别名
if command -v git >/dev/null 2>&1; then
    alias gs='git status'
    alias ga='git add'
    alias gc='git commit'
    alias gp='git push'
    alias gl='git pull'
    alias gd='git diff'
    alias gb='git branch'
    alias gco='git checkout'
fi

# 综合工具别名（基于可用性）
alias search='search-all'
alias analyze='project-analyze'
alias large='find-large-files'
alias recent='find-recent'
alias port='port-check'
alias info='sysinfo'

# 快速编辑常用配置文件
alias zshrc='${EDITOR:-vim} ~/.zshrc'
alias vimrc='${EDITOR:-vim} ~/.vimrc'
alias bashrc='${EDITOR:-vim} ~/.bashrc'

# 系统工具别名
if command -v btop >/dev/null 2>&1; then
    alias top='btop'
    alias htop='btop'
fi

if command -v ncdu >/dev/null 2>&1; then
    alias du='ncdu'
fi

# 网络工具别名
if command -v mtr >/dev/null 2>&1; then
    alias mtr='mtr --show-ips'
fi

if command -v nmap >/dev/null 2>&1; then
    # 快速端口扫描
    alias nmap-quick='nmap -T4 -F'
    # 详细扫描
    alias nmap-detail='nmap -T4 -A -v'
fi

# 显示可用的工具组合命令 - 基于ADVANCED.md的全面功能
show-tools() {
    echo "==> 🚀 Shell Tools 模块化配置系统 v2.0 <=="
    echo
    echo "📁 文件搜索和预览:"
    echo "  fe          - 交互式文件编辑"
    echo "  fo          - 用默认应用打开文件"
    echo "  vf          - 交互式文件查看（bat预览）"
    echo "  fcd         - fzf + fd: 搜索并切换目录"
    echo "  fp          - fzf: 快速跳转项目目录"
    echo "  fc          - fzf + rg: 搜索文件内容"
    echo "  fthemes     - fzf + bat: 预览 bat 主题"
    echo
    echo "📂 目录导航增强:"
    echo "  fdir        - 基础目录切换"
    echo "  fdira       - 包含隐藏目录的切换"
    echo "  fdirt       - 树形预览目录切换"
    echo
    echo "🔄 动态重载和模式切换:"
    echo "  fps         - fzf动态进程管理 (CTRL-R重载)"
    echo "  ffd         - 文件/目录动态切换 (CTRL-D/CTRL-F)"
    echo "  ftm         - 单键模式切换 (CTRL-T)"
    echo "  fzf-popup   - tmux popup模式 (需要tmux 3.3+)"
    echo
    echo "🔍 高级搜索功能:"
    echo "  rfv         - Ripgrep + fzf二级过滤"
    echo "  rgi         - 交互式Ripgrep启动器"
    echo "  rg2         - 双阶段搜索 (ALT-ENTER切换)"
    echo "  batgrep     - Ripgrep + bat集成搜索"
    echo "  rg-fzf      - 搜索后选择文件查看"
    echo
    echo "📖 Man页面和文档:"
    echo "  batman      - fzf + bat: 交互式man页面浏览"
    echo "  fman        - fzf: man页面搜索"
    echo "  man-search  - man + fzf: 搜索man页面"
    echo
    echo "📊 日志监控:"
    echo "  flog        - 交互式日志文件选择"
    echo "  tailbat     - tail + bat: 实时日志监控"
    echo "  tailsys     - 系统日志监控"
    echo "  tailauth    - 认证日志监控"
    echo
    echo "🔧 系统分析和工具:"
    echo "  search      - 综合搜索（文件名+内容）"
    echo "  analyze     - 项目结构分析"
    echo "  large       - 查找大文件"
    echo "  recent      - 查找最近修改的文件"
    echo "  port        - 端口占用检查"
    echo "  info        - 系统信息概览"
    echo
    echo "📦 APT软件包管理 (Ubuntu/Debian):"
    echo "  af          - 交互式搜索和安装APT软件包"
    echo "  as          - APT软件包搜索（不安装）"
    echo "  ai          - 已安装软件包管理"
    echo "  ainfo       - 软件包详细信息"
    echo
    echo "🔧 调试和管理:"
    echo "  shell-tools-debug   - 详细调试信息"
    echo "  shell-tools-status  - 模块加载状态"
    echo "  shell-tools-reload  - 重新加载所有模块"
    echo
    echo "💡 提示: 所有功能基于模块化设计，可独立加载和调试"
    echo "📚 基于官方fzf ADVANCED.md文档实现的全面功能集"
}
'''

def handle_legacy_config():
    """处理旧版配置文件的迁移"""
    if OLD_CONFIG_FILE.exists():
        log_warn(f"检测到旧版配置文件: {OLD_CONFIG_FILE}")
        log_info("新版本使用模块化配置，旧文件将被备份")

        # 备份旧文件
        backup_file = OLD_CONFIG_FILE.with_suffix('.zsh.backup')
        try:
            OLD_CONFIG_FILE.rename(backup_file)
            log_success(f"旧配置文件已备份到: {backup_file}")
        except Exception as e:
            log_warn(f"备份旧配置文件失败: {str(e)}")

    return True

def update_zshrc_for_modular_config():
    """更新.zshrc文件以使用模块化配置"""
    zshrc_path = Path.home() / ".zshrc"

    # 新的配置行
    new_config_lines = [
        "# Shell Tools Modular Configuration - Auto-generated by shell-tools-config-generator.py v2.0",
        "[[ -f ~/.oh-my-zsh/custom/shell-tools-main.zsh ]] && source ~/.oh-my-zsh/custom/shell-tools-main.zsh"
    ]

    # 旧的配置行（需要移除）
    old_config_patterns = [
        "# Shell Tools Configuration - Auto-generated by shell-tools-config-generator.py",
        "[[ -f ~/.shell-tools-config.zsh ]] && source ~/.shell-tools-config.zsh"
    ]

    if not zshrc_path.exists():
        log_warn(".zshrc文件不存在，创建新文件")
        with open(zshrc_path, 'w') as f:
            f.write('\n'.join(new_config_lines) + '\n')
        return True

    try:
        # 读取现有内容
        with open(zshrc_path, 'r') as f:
            lines = f.readlines()

        # 移除旧的配置行
        lines = [line for line in lines if not any(pattern in line for pattern in old_config_patterns)]

        # 检查是否已经有新的配置
        has_new_config = any(new_config_lines[1] in line for line in lines)

        if not has_new_config:
            # 添加新的配置行
            lines.extend([line + '\n' for line in new_config_lines])

            with open(zshrc_path, 'w') as f:
                f.writelines(lines)

            log_success("已更新.zshrc文件以使用模块化配置")
        else:
            log_info("Shell工具模块化配置引用已存在于.zshrc中")

        return True

    except Exception as e:
        log_error(f"更新.zshrc文件失败: {str(e)}")
        return False

def main():
    """主函数 - 模块化版本"""
    show_header("Shell工具配置生成器", "2.0", "生成模块化的现代shell工具最佳实践配置")

    log_info("开始生成Shell工具模块化配置...")

    # 处理旧版配置文件
    if not handle_legacy_config():
        log_error("处理旧版配置失败")
        return False

    # 生成模块化配置文件
    if not generate_shell_tools_config():
        log_error("Shell工具配置文件生成失败")
        return False

    # 更新.zshrc文件
    if not update_zshrc_for_modular_config():
        log_error(".zshrc文件更新失败")
        return False

    log_success("Shell工具模块化配置生成完成！")
    log_info("请运行 'source ~/.zshrc' 或重新启动终端以应用配置")
    log_info("运行 'shell-tools-debug' 查看模块加载状态")

    return True

if __name__ == "__main__":
    main()
