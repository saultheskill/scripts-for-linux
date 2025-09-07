#!/usr/bin/env python3

"""
模块生成器
包含所有shell配置模块的内容生成函数
"""

from typing import Dict, Any


class ModuleGenerators:
    """Shell配置模块生成器"""

    def __init__(self):
        pass

    def generate_path_config_module(self) -> str:
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

    def generate_tool_detection_module(self) -> str:
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

    def generate_bat_config_module(self) -> str:
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

    def generate_fd_config_module(self) -> str:
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

    def generate_main_config_content(self) -> str:
        """生成主配置文件内容"""
        return '''# =============================================================================
# Shell Tools Main Configuration - 模块化配置系统
# 由 shell-tools-config-generator.py v2.1 自动生成
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

    def generate_debug_module_content(self) -> str:
        """生成调试模块内容"""
        return '''# =============================================================================
# Shell Tools Debug Module - 调试和诊断功能
# =============================================================================

# 增强的调试函数：检查工具安装状态和模块加载情况
shell-tools-debug() {
    echo "=== Shell Tools Debug Information ==="
    echo "版本: 2.1 (模块化重构版)"
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
    if [[ -n "${SHELL_TOOLS_MODULES_LOADED[*]}" ]]; then
        for module in "${!SHELL_TOOLS_MODULES_LOADED[@]}"; do
            echo "  ✓ $module"
        done
    else
        echo "  无已加载模块"
    fi

    if [[ -n "${SHELL_TOOLS_MODULES_FAILED[*]}" ]]; then
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

    def generate_fzf_basic_module(self) -> str:
        """生成fzf基础功能模块"""
        return '''# fzf基础功能（文件搜索、编辑等）

if command -v fzf >/dev/null 2>&1; then
    # 确定使用的bat命令
    if command -v batcat >/dev/null 2>&1; then
        local bat_cmd='batcat'
    elif command -v bat >/dev/null 2>&1; then
        local bat_cmd='bat'
    else
        local bat_cmd='cat'
    fi

    # 基础文件搜索和编辑功能
    # 使用fzf搜索文件并用默认编辑器打开
    fe() {
        local files
        IFS=$'\\n' files=($(fzf-tmux --query="$1" --multi --select-1 --exit-0))
        [[ -n "$files" ]] && ${EDITOR:-vim} "${files[@]}"
    }

    # 使用fzf搜索文件并用bat预览
    fp() {
        fzf --preview "$bat_cmd --color=always --style=numbers --line-range=:500 {}" "$@"
    }

    # 搜索文件内容并编辑
    fif() {
        if [ ! "$#" -gt 0 ]; then
            echo "用法: fif <搜索词>"
            return 1
        fi

        # 使用rg搜索，如果没有则使用grep
        if command -v rg >/dev/null 2>&1; then
            local file
            file="$(rg --files-with-matches --no-messages "$1" | fzf --preview "rg --ignore-case --pretty --context 10 '$1' {}")" &&
            ${EDITOR:-vim} "$file"
        else
            local file
            file="$(grep -r -l "$1" . | fzf --preview "grep --color=always -n '$1' {}")" &&
            ${EDITOR:-vim} "$file"
        fi
    }

    # 快速目录跳转
    fcd() {
        local dir
        # 使用fd查找目录，如果没有则使用find
        if command -v fd >/dev/null 2>&1; then
            dir=$(fd --type d --hidden --follow --exclude .git | fzf +m) &&
            cd "$dir"
        elif command -v fdfind >/dev/null 2>&1; then
            dir=$(fdfind --type d --hidden --follow --exclude .git | fzf +m) &&
            cd "$dir"
        else
            dir=$(find . -type d -not -path '*/\\.git/*' | fzf +m) &&
            cd "$dir"
        fi
    }

    # 历史命令搜索增强
    fh() {
        print -z $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed -E 's/ *[0-9]*\\*? *//' | sed -E 's/\\\\\\\\n/\\\\n/')
    }

    # 进程查看和终止
    fkill() {
        local pid
        if [ "$UID" != "0" ]; then
            pid=$(ps -f -u $UID | sed 1d | fzf -m | awk '{print $2}')
        else
            pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
        fi

        if [ "x$pid" != "x" ]; then
            echo $pid | xargs kill -${1:-9}
        fi
    }

    # 别名
    alias ff='fp'           # 文件预览
    alias fed='fe'          # 文件编辑
    alias fdir='fcd'        # 目录跳转
    alias fhist='fh'        # 历史搜索
fi
'''

    def generate_fzf_advanced_module(self) -> str:
        """生成fzf高级功能模块"""
        return '''# fzf高级功能（动态重载、模式切换等）

if command -v fzf >/dev/null 2>&1; then
    # 高级文件搜索 - 支持多种搜索模式切换
    fzf-multi-search() {
        local initial_query=""
        local search_mode="files"

        while true; do
            case "$search_mode" in
                "files")
                    if command -v fd >/dev/null 2>&1; then
                        result=$(fd --type f --hidden --follow --exclude .git | \\
                            fzf --query="$initial_query" \\
                                --header="文件搜索模式 | F1:内容搜索 F2:目录搜索 F3:Git文件" \\
                                --bind="f1:execute-silent(echo content)+abort" \\
                                --bind="f2:execute-silent(echo dirs)+abort" \\
                                --bind="f3:execute-silent(echo git)+abort" \\
                                --preview="bat --color=always --style=numbers --line-range=:500 {}")
                    else
                        result=$(find . -type f -not -path '*/\\.git/*' | \\
                            fzf --query="$initial_query" \\
                                --header="文件搜索模式 | F1:内容搜索 F2:目录搜索" \\
                                --bind="f1:execute-silent(echo content)+abort" \\
                                --bind="f2:execute-silent(echo dirs)+abort" \\
                                --preview="cat {}")
                    fi
                    ;;
                "content")
                    if command -v rg >/dev/null 2>&1; then
                        result=$(rg --line-number --no-heading --color=always --smart-case "$initial_query" | \\
                            fzf --ansi \\
                                --header="内容搜索模式 | F1:文件搜索 F2:目录搜索" \\
                                --bind="f1:execute-silent(echo files)+abort" \\
                                --bind="f2:execute-silent(echo dirs)+abort" \\
                                --delimiter : \\
                                --preview 'bat --color=always --line-range {2}: {1}')
                    else
                        result=$(grep -r -n --color=always "$initial_query" . | \\
                            fzf --ansi \\
                                --header="内容搜索模式 | F1:文件搜索 F2:目录搜索" \\
                                --bind="f1:execute-silent(echo files)+abort" \\
                                --bind="f2:execute-silent(echo dirs)+abort")
                    fi
                    ;;
                "dirs")
                    if command -v fd >/dev/null 2>&1; then
                        result=$(fd --type d --hidden --follow --exclude .git | \\
                            fzf --query="$initial_query" \\
                                --header="目录搜索模式 | F1:文件搜索 F2:内容搜索" \\
                                --bind="f1:execute-silent(echo files)+abort" \\
                                --bind="f2:execute-silent(echo content)+abort")
                    else
                        result=$(find . -type d -not -path '*/\\.git/*' | \\
                            fzf --query="$initial_query" \\
                                --header="目录搜索模式 | F1:文件搜索 F2:内容搜索" \\
                                --bind="f1:execute-silent(echo files)+abort" \\
                                --bind="f2:execute-silent(echo content)+abort")
                    fi
                    ;;
                "git")
                    if command -v git >/dev/null 2>&1; then
                        result=$(git ls-files | \\
                            fzf --query="$initial_query" \\
                                --header="Git文件搜索模式 | F1:文件搜索 F2:内容搜索" \\
                                --bind="f1:execute-silent(echo files)+abort" \\
                                --bind="f2:execute-silent(echo content)+abort" \\
                                --preview="bat --color=always --style=numbers --line-range=:500 {}")
                    fi
                    ;;
            esac

            # 检查结果并决定下一步
            if [[ "$result" == "files" ]]; then
                search_mode="files"
                continue
            elif [[ "$result" == "content" ]]; then
                search_mode="content"
                continue
            elif [[ "$result" == "dirs" ]]; then
                search_mode="dirs"
                continue
            elif [[ "$result" == "git" ]]; then
                search_mode="git"
                continue
            elif [[ -n "$result" ]]; then
                echo "$result"
                break
            else
                break
            fi
        done
    }

    # 动态重载搜索
    fzf-reload() {
        local reload_command="find . -type f -not -path '*/\\.git/*'"
        if command -v fd >/dev/null 2>&1; then
            reload_command="fd --type f --hidden --follow --exclude .git"
        fi

        $reload_command | fzf --bind "ctrl-r:reload($reload_command)" \\
                             --header "CTRL-R: 重新加载文件列表" \\
                             --preview "bat --color=always --style=numbers --line-range=:500 {}"
    }

    # 别名
    alias fms='fzf-multi-search'    # 多模式搜索
    alias frl='fzf-reload'          # 动态重载搜索
fi
'''

    def generate_ripgrep_config_module(self) -> str:
        """生成ripgrep配置模块"""
        return '''# ripgrep配置和基础集成

if command -v rg >/dev/null 2>&1; then
    # ripgrep 环境变量配置
    export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"

    # 创建ripgrep配置文件（如果不存在）
    if [[ ! -f "$RIPGREP_CONFIG_PATH" ]]; then
        cat > "$RIPGREP_CONFIG_PATH" << 'EOF'
# ripgrep配置文件
--max-columns=150
--max-columns-preview
--smart-case
--follow
--hidden
--glob=!.git/*
--glob=!node_modules/*
--glob=!.cache/*
--glob=!*.lock
--colors=line:none
--colors=line:style:bold
--colors=path:fg:green
--colors=path:style:bold
--colors=match:fg:black
--colors=match:bg:yellow
--colors=match:style:nobold
EOF
    fi

    # 基础ripgrep别名
    alias rgi='rg --ignore-case'                    # 忽略大小写搜索
    alias rgf='rg --files'                          # 列出将被搜索的文件
    alias rgl='rg --files-with-matches'             # 只显示匹配的文件名
    alias rgL='rg --files-without-match'            # 只显示不匹配的文件名
    alias rgv='rg --invert-match'                   # 反向匹配
    alias rgw='rg --word-regexp'                    # 全词匹配
    alias rgA='rg --after-context'                  # 显示匹配后的行
    alias rgB='rg --before-context'                 # 显示匹配前的行
    alias rgC='rg --context'                        # 显示匹配前后的行

    # 按文件类型搜索
    rg-py() { rg --type py "$@"; }                  # Python文件
    rg-js() { rg --type js "$@"; }                  # JavaScript文件
    rg-css() { rg --type css "$@"; }                # CSS文件
    rg-html() { rg --type html "$@"; }              # HTML文件
    rg-md() { rg --type md "$@"; }                  # Markdown文件
    rg-json() { rg --type json "$@"; }              # JSON文件
    rg-yaml() { rg --type yaml "$@"; }              # YAML文件
    rg-sh() { rg --type sh "$@"; }                  # Shell脚本

    # 搜索统计
    rg-stats() {
        if [[ $# -eq 0 ]]; then
            echo "用法: rg-stats <搜索词>"
            return 1
        fi
        echo "搜索统计: $1"
        echo "匹配文件数: $(rg -l "$1" | wc -l)"
        echo "匹配行数: $(rg -c "$1" | awk -F: '{sum += $2} END {print sum}')"
        echo "总匹配数: $(rg "$1" | wc -l)"
    }
fi
'''

    def generate_ripgrep_fzf_module(self) -> str:
        """生成ripgrep+fzf集成模块"""
        return '''# ripgrep + fzf高级集成功能

if command -v rg >/dev/null 2>&1 && command -v fzf >/dev/null 2>&1; then
    # 确定使用的bat命令
    if command -v batcat >/dev/null 2>&1; then
        local bat_cmd='batcat'
    elif command -v bat >/dev/null 2>&1; then
        local bat_cmd='bat'
    else
        local bat_cmd='cat'
    fi

    # 交互式ripgrep搜索 - 主要功能
    rgf() {
        local initial_query="${*:-}"
        local rg_prefix="rg --column --line-number --no-heading --color=always --smart-case"
        local fzf_default_opts="
            --ansi
            --disabled
            --query=\"$initial_query\"
            --bind=\"change:reload:sleep 0.1; $rg_prefix {q} || true\"
            --bind=\"ctrl-f:unbind(change,ctrl-f)+change-prompt(2. fzf> )+enable-search+clear-query+rebind(ctrl-r)\"
            --bind=\"ctrl-r:unbind(ctrl-r)+change-prompt(1. ripgrep> )+disable-search+reload($rg_prefix {q} || true)+rebind(change,ctrl-f)\"
            --color=\"hl:-1:underline,hl+:-1:underline:reverse\"
            --prompt=\"1. ripgrep> \"
            --delimiter=:
            --header=\"CTRL-F: 切换到fzf模式 | CTRL-R: 切换到ripgrep模式\"
            --preview=\"$bat_cmd --color=always {1} --highlight-line {2}\"
            --preview-window=\"up,60%,border-bottom,+{2}+3/3,~3\"
        "

        FZF_DEFAULT_OPTS="$fzf_default_opts" fzf
    }

    # 在当前目录搜索并编辑
    rge() {
        local file line
        read -r file line <<< "$(rgf "$@" | head -1 | awk -F: '{print $1, $2}')"
        if [[ -n "$file" ]]; then
            ${EDITOR:-vim} +"$line" "$file"
        fi
    }

    # 搜索并显示上下文
    rgc() {
        if [[ $# -eq 0 ]]; then
            echo "用法: rgc <搜索词> [上下文行数，默认3]"
            return 1
        fi
        local context=${2:-3}
        rg --context "$context" --color=always "$1" | fzf --ansi --preview="echo {}" --preview-window=up:50%
    }

    # 多文件类型搜索
    rgm() {
        if [[ $# -eq 0 ]]; then
            echo "用法: rgm <搜索词>"
            echo "支持的文件类型: py, js, css, html, md, json, yaml, sh"
            return 1
        fi

        local query="$1"
        local types=("py" "js" "css" "html" "md" "json" "yaml" "sh")

        for type in "${types[@]}"; do
            echo "=== $type 文件 ==="
            rg --type "$type" --color=always "$query" | head -5
            echo
        done | fzf --ansi --preview="echo {}" --header="多文件类型搜索结果: $query"
    }

    # 搜索替换预览
    rgs() {
        if [[ $# -lt 2 ]]; then
            echo "用法: rgs <搜索词> <替换词> [文件模式]"
            return 1
        fi

        local search="$1"
        local replace="$2"
        local pattern="${3:-.}"

        echo "搜索替换预览:"
        echo "搜索: $search"
        echo "替换: $replace"
        echo "范围: $pattern"
        echo

        rg --color=always "$search" "$pattern" | \\
        fzf --ansi \\
            --preview="echo '原文:'; echo {}; echo; echo '替换后:'; echo {} | sed 's/$search/$replace/g'" \\
            --header="预览搜索替换结果 | ENTER: 执行替换"

        read -q "REPLY?确认执行替换操作? (y/N): "
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rg --files-with-matches "$search" "$pattern" | xargs sed -i "s/$search/$replace/g"
            echo "替换完成"
        fi
    }

    # 别名
    alias rgfzf='rgf'       # ripgrep + fzf交互搜索
    alias rged='rge'        # 搜索并编辑
    alias rgctx='rgc'       # 搜索显示上下文
    alias rgmulti='rgm'     # 多文件类型搜索
    alias rgreplace='rgs'   # 搜索替换预览
fi
'''
