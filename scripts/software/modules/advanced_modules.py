#!/usr/bin/env python3

"""
高级模块生成器
包含fzf、git、man等复杂功能模块的生成函数
"""


class AdvancedModuleGenerators:
    """高级Shell配置模块生成器"""

    def __init__(self):
        pass

    def generate_fzf_core_module(self) -> str:
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

    # 使用 fd/fdfind 作为 fzf 的默认搜索命令（如果可用）
    # 优先检查 fdfind，然后检查 fd 别名
    if command -v fdfind >/dev/null 2>&1; then
        export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --follow --exclude .git --exclude node_modules --exclude .cache'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_ALT_C_COMMAND='fdfind --type d --hidden --follow --exclude .git --exclude node_modules --exclude .cache'
    elif command -v fd >/dev/null 2>&1; then
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

    def generate_man_integration_module(self) -> str:
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
            man -k . | fzf -q "$1" --prompt='man> ' --preview 'echo {} | tr -d "()" | awk "{printf \"%s \", \\$2} {print \\$1}" | xargs -r man' | tr -d '()' | awk '{printf "%s ", $2} {print $1}' | xargs -r man
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
            man -k . 2>/dev/null | \\
            awk '{
                # 提取命令名（去掉括号内容）
                cmd = $1
                gsub(/\\([^)]*\\)/, "", cmd)
                # 提取描述
                desc = ""
                for(i=2; i<=NF; i++) desc = desc " " $i
                printf "%-20s %s\\n", cmd, desc
            }' | \\
            sort | \\
            fzf \\
                --query="$1" \\
                --ansi \\
                --tiebreak=begin \\
                --prompt=' Man > ' \\
                --preview-window '50%,rounded,<50(up,85%,border-bottom)' \\
                --preview "echo {} | awk '{print \\$1}' | xargs -I {} sh -c 'man {} 2>/dev/null | col -bx | $bat_cmd --language=man --plain --color=always --theme=OneHalfDark || echo \"Manual not found for {}\"'" \\
                --bind "enter:execute(echo {} | awk '{print \\$1}' | xargs -r man)" \\
                --bind "alt-c:+change-preview(echo {} | awk '{print \\$1}' | xargs -I {} sh -c 'curl -s cht.sh/{} 2>/dev/null || echo \"cheat.sh not available for {}\"')+change-prompt(' Cheat > ')" \\
                --bind "alt-t:+change-preview(echo {} | awk '{print \\$1}' | xargs -I {} sh -c 'tldr --color=always {} 2>/dev/null || echo \"tldr not available for {}\"')+change-prompt(' TLDR > ')" \\
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

    def generate_apt_integration_module(self) -> str:
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
        fzf --multi --cycle --reverse \\
            --query="$*" \\
            --preview-window=right:70%:wrap \\
            --preview "apt-cache show {1}" \\
            --header "搜索: $* | TAB: 多选 | ENTER: 查看详情 | ESC: 退出" |
        cut --delimiter " " --fields 1
    }

    # APT已安装软件包管理
    apt-installed() {
        dpkg --get-selections | grep -v deinstall | cut -f1 |
        fzf --multi --cycle --reverse \\
            --preview-window=right:70%:wrap \\
            --preview "apt-cache show {1}" \\
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
