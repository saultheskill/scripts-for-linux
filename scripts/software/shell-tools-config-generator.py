#!/usr/bin/env python3

"""
Shell工具配置生成器
作者: saul
版本: 1.0
描述: 生成fd、fzf等现代shell工具的最佳实践配置
"""

import os
import sys
from pathlib import Path

# 添加scripts目录到Python路径
script_dir = Path(__file__).parent
sys.path.insert(0, str(script_dir.parent))

try:
    from common import *
except ImportError:
    print("错误：无法导入common模块")
    sys.exit(1)

def generate_shell_tools_config():
    """
    生成shell工具配置文件

    Returns:
        bool: 生成是否成功
    """
    config_path = Path.home() / ".shell-tools-config.zsh"

    config_content = '''# =============================================================================
# Shell Tools Configuration - 现代shell工具最佳实践配置
# 由 shell-tools-config-generator.py 自动生成
# 集成了 fzf、bat、fd、ripgrep、git 等工具的高级组合功能
# =============================================================================

# =============================================================================
# 环境变量和PATH配置
# =============================================================================

# 修复Ubuntu/Debian系统PATH问题 - 确保/bin和/usr/bin在PATH中
case ":$PATH:" in
    *:/bin:*) ;;
    *) export PATH="/bin:$PATH" ;;
esac

case ":$PATH:" in
    *:/usr/bin:*) ;;
    *) export PATH="/usr/bin:$PATH" ;;
esac

# =============================================================================
# 工具可用性检测和别名统一化
# =============================================================================

# 检测并统一 bat 命令（Ubuntu/Debian 使用 batcat）
if command -v batcat >/dev/null 2>&1; then
    alias bat='batcat'
elif command -v bat >/dev/null 2>&1; then
    # bat 已经可用，无需别名
    :
fi

# 检测并统一 fd 命令（Ubuntu/Debian 使用 fdfind）
if command -v fdfind >/dev/null 2>&1; then
    alias fd='fdfind'
elif command -v fd >/dev/null 2>&1; then
    # fd 已经可用，无需别名
    :
fi

# =============================================================================
# bat (cat的增强版) 核心配置
# =============================================================================

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

# =============================================================================
# fd (find的现代替代品) 配置
# =============================================================================

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

# =============================================================================
# fzf (模糊查找工具) 高级配置与集成
# 基于官方 ADVANCED.md 文档的全面配置
# =============================================================================

if command -v fzf >/dev/null 2>&1; then
    # =============================================================================
    # fzf 核心显示配置 - 基于官方高级示例
    # =============================================================================

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

    # =============================================================================
    # tmux 集成配置 - 基于官方ADVANCED.md的tmux popup功能
    # =============================================================================

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

    # =============================================================================
    # 基于官方ADVANCED.md的动态重载和进程管理功能
    # =============================================================================

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

    # =============================================================================
    # 基于fzf-basic-example.md的文件操作增强功能
    # =============================================================================

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
    alias fps='fzf-processes'     # 动态进程管理
    alias ffd='fzf-files-dirs'    # 文件目录切换
    alias ftm='fzf-toggle-mode'   # 单键模式切换

    # =============================================================================
    # 基于fzf-basic-example.md的历史命令和进程管理功能
    # =============================================================================

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

    # 新增别名 - 基于basic example
    # fe, fo, vf 已经定义为函数
    alias fdir-basic='fdir'       # 基础目录切换
    alias fdira-all='fdira'       # 包含隐藏目录
    alias fdirt-tree='fdirt'      # 树形预览目录

    # =============================================================================
    # 基于fzf-basic-example.md的tmux集成功能
    # =============================================================================

    # tmux会话管理 - 基于basic example的tm函数
    if command -v tmux >/dev/null 2>&1; then
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

    # 历史和进程管理别名
    alias fhist='fh'              # 历史命令搜索
    alias fkill-proc='fkill'      # 进程终止
    alias find-in-files='fif'     # 文件内容搜索
    alias vim-grep='vg'           # 搜索并编辑
fi

# =============================================================================
# ripgrep + bat 集成：高级搜索和语法高亮
# =============================================================================

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

    # =============================================================================
    # 基于官方ADVANCED.md的高级Ripgrep集成功能
    # =============================================================================

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

        # 4. Ripgrep和fzf模式切换 - 基于文档示例
        rgs() {
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

            # 创建临时文件存储查询状态
            local tmp_r="/tmp/rg-fzf-r-$$"
            local tmp_f="/tmp/rg-fzf-f-$$"
            echo "$INITIAL_QUERY" > "$tmp_r"
            echo "" > "$tmp_f"

            fzf --ansi --disabled --query "$INITIAL_QUERY" \
                --bind "start:reload($RG_PREFIX {q})+unbind(ctrl-r)" \
                --bind "change:reload:sleep 0.1; $RG_PREFIX {q} || true" \
                --bind "ctrl-f:unbind(change,ctrl-f)+change-prompt(2. fzf> )+enable-search+rebind(ctrl-r)+transform-query(echo {q} > $tmp_r; cat $tmp_f)" \
                --bind "ctrl-r:unbind(ctrl-r)+change-prompt(1. ripgrep> )+disable-search+reload($RG_PREFIX {q} || true)+rebind(change,ctrl-f)+transform-query(echo {q} > $tmp_f; cat $tmp_r)" \
                --color "hl:-1:underline,hl+:-1:underline:reverse" \
                --prompt '1. ripgrep> ' \
                --delimiter : \
                --header '╱ CTRL-R (ripgrep mode) ╱ CTRL-F (fzf mode) ╱' \
                --preview "$bat_cmd --color=always {1} --highlight-line {2}" \
                --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
                --bind 'enter:become(vim {1} +{2})' \
                --bind "ctrl-c:execute(rm -f $tmp_r $tmp_f)"

            # 清理临时文件
            rm -f "$tmp_r" "$tmp_f" 2>/dev/null
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

    # 实用别名
    alias rgg='rg --group --color=always'
    alias rgf='rg --files-with-matches'
    alias rgl='rg --files-without-match'
fi

# =============================================================================
# git + bat 集成：增强的 Git 操作
# =============================================================================

if command -v git >/dev/null 2>&1 && (command -v bat >/dev/null 2>&1 || command -v batcat >/dev/null 2>&1); then
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

    # =============================================================================
    # 基于官方ADVANCED.md的Git对象键绑定功能
    # =============================================================================

    # Git状态文件交互选择
    fzf-git-status() {
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

        git status --porcelain |
        fzf --multi \
            --preview "git diff --color=always \$(echo {} | awk '{print \$2}') | $bat_cmd --language=diff" \
            --preview-window 'right:60%:wrap' \
            --header 'CTRL-A: Add | CTRL-R: Reset | CTRL-D: Diff | Enter: Edit' \
            --bind 'ctrl-a:execute(git add $(echo {} | awk "{print \$2}"))' \
            --bind 'ctrl-r:execute(git reset $(echo {} | awk "{print \$2}"))' \
            --bind "ctrl-d:execute(git diff \$(echo {} | awk '{print \$2}') | $bat_cmd --language=diff --paging=always)" \
            --bind 'enter:become(${EDITOR:-vim} $(echo {} | awk "{print \$2}"))'
    }

    # Git分支交互选择
    fzf-git-branch() {
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

        git branch -a --color=always |
        grep -v '/HEAD\\s' |
        fzf --ansi \
            --multi \
            --preview 'git log --oneline --graph --date=short --color=always --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1) | head -200' \
            --preview-window 'right:60%:wrap' \
            --header 'CTRL-O: Checkout | CTRL-D: Delete | CTRL-M: Merge | Enter: Show log' \
            --bind 'ctrl-o:execute(git checkout $(sed s/^..// <<< {} | cut -d" " -f1))' \
            --bind 'ctrl-d:execute(git branch -d $(sed s/^..// <<< {} | cut -d" " -f1))' \
            --bind 'ctrl-m:execute(git merge $(sed s/^..// <<< {} | cut -d" " -f1))' \
            --bind "enter:execute(git log --oneline --graph --color=always \$(sed s/^..// <<< {} | cut -d' ' -f1) | $bat_cmd --language=gitlog --paging=always)"
    }

    # Git提交哈希交互选择
    fzf-git-commits() {
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

        git log --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
        fzf --ansi \
            --no-sort \
            --reverse \
            --multi \
            --preview "git show --color=always {1} | $bat_cmd --language=diff" \
            --preview-window 'right:60%:wrap' \
            --header 'CTRL-S: Show | CTRL-D: Diff | CTRL-R: Reset | Enter: Show details' \
            --bind "ctrl-s:execute(git show {1} | $bat_cmd --language=diff --paging=always)" \
            --bind "ctrl-d:execute(git diff {1}^ {1} | $bat_cmd --language=diff --paging=always)" \
            --bind 'ctrl-r:execute(git reset --hard {1})' \
            --bind "enter:execute(git show --stat --color=always {1} | $bat_cmd --language=gitlog --paging=always)"
    }

    # Git标签交互选择
    fzf-git-tags() {
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

        git tag --sort=-version:refname |
        fzf --multi \
            --preview "git show --color=always {} | $bat_cmd --language=diff" \
            --preview-window 'right:60%:wrap' \
            --header 'CTRL-O: Checkout | CTRL-D: Delete | Enter: Show' \
            --bind 'ctrl-o:execute(git checkout {})' \
            --bind 'ctrl-d:execute(git tag -d {})' \
            --bind "enter:execute(git show --color=always {} | $bat_cmd --language=diff --paging=always)"
    }

    # Git别名 - 包含新的交互功能
    alias gshow='git-show-bat'
    alias gdiff='batdiff'
    alias glog='git-log-bat'
    alias gst='fzf-git-status'      # Git状态交互
    alias gbr='fzf-git-branch'      # Git分支交互
    alias gco='fzf-git-commits'     # Git提交交互
    alias gtg='fzf-git-tags'        # Git标签交互
fi

# =============================================================================
# tail + bat 集成：日志监控与语法高亮
# =============================================================================

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

    # 多文件日志监控
    multitail-bat() {
        if [[ $# -eq 0 ]]; then
            echo "用法: multitail-bat <文件1> [文件2] ..."
            return 1
        fi

        for file in "$@"; do
            if [[ -f "$file" ]]; then
                echo "==> 监控: $file <=="
                # 使用动态检测的bat命令
                if command -v batcat >/dev/null 2>&1; then
                    tail -f "$file" | batcat --paging=never -l log &
                elif command -v bat >/dev/null 2>&1; then
                    tail -f "$file" | bat --paging=never -l log &
                else
                    tail -f "$file" &
                fi
            fi
        done
        wait
    }

    # =============================================================================
    # 基于官方ADVANCED.md的高级日志监控功能
    # =============================================================================

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

    # 多日志文件并行监控
    fzf-multi-log-tail() {
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

        local log_dirs=("/var/log" "/var/log/nginx" "/var/log/apache2")
        local selected_logs

        selected_logs=$(find "${log_dirs[@]}" -name "*.log" -o -name "syslog*" 2>/dev/null |
                       fzf --multi \
                           --preview "tail -20 {} | $bat_cmd --color=always -l log" \
                           --preview-window 'right:50%:wrap' \
                           --header 'Select multiple log files to monitor (TAB to select)')

        if [[ -n "$selected_logs" ]]; then
            echo "监控以下日志文件:"
            echo "$selected_logs"
            echo "按 Ctrl+C 停止监控"
            echo

            # 使用multitail或者简单的并行tail
            if command -v multitail >/dev/null 2>&1; then
                multitail $(echo "$selected_logs" | tr '\n' ' ')
            else
                # 简单的并行tail实现
                echo "$selected_logs" | while read -r logfile; do
                    (echo "==> $logfile <=="; tail -f "$logfile" | sed "s/^/[$logfile] /") &
                done | "$bat_cmd" --paging=never -l log
            fi
        fi
    }

    # 日志级别过滤监控
    fzf-log-level() {
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
            echo "用法: fzf-log-level <日志文件>"
            return 1
        fi

        local logfile="$1"
        local levels=("ERROR" "WARN" "INFO" "DEBUG" "TRACE" "ALL")

        printf '%s\n' "${levels[@]}" |
        fzf --preview "grep -i {} '$logfile' | tail -50 | $bat_cmd --color=always -l log" \
            --preview-window 'down:60%:wrap' \
            --header 'Select log level to monitor' \
            --bind "enter:execute(if [[ {} == 'ALL' ]]; then tail -f '$logfile' | $bat_cmd --paging=never -l log; else tail -f '$logfile' | grep -i {} | $bat_cmd --paging=never -l log; fi)"
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
    alias flog='fzf-log-tail'          # 交互式日志选择
    alias fmlogs='fzf-multi-log-tail'  # 多日志监控
    alias flevel='fzf-log-level'       # 日志级别过滤
fi

# =============================================================================
# man + bat 集成：彩色 man 页面
# =============================================================================

if command -v bat >/dev/null 2>&1 || command -v batcat >/dev/null 2>&1; then
    # 设置 MANPAGER 使用 bat 作为 man 页面的分页器 - 修复兼容性
    if command -v batcat >/dev/null 2>&1; then
        export MANPAGER="sh -c 'col -bx | batcat -l man -p'"
    elif command -v bat >/dev/null 2>&1; then
        export MANPAGER="sh -c 'col -bx | bat -l man -p'"
    fi

    # 基于fzf-basic-example.md的高级man页面功能
    if command -v fzf >/dev/null 2>&1; then
        # 简单的man页面搜索 - 基于basic example
        fman() {
            man -k . | fzf -q "$1" --prompt='man> ' --preview 'echo {} | tr -d "()" | awk "{printf \"%s \", \$2} {print \$1}" | xargs -r man' | tr -d '()' | awk '{printf "%s ", $2} {print $1}' | xargs -r man
        }

        # 高级man页面widget - 修复搜索和主题问题
        fzf-man-widget() {
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

            # 修复：使用有效的bat主题和简化的预览命令
            local preview_cmd="echo {} | awk '{print \$1}' | xargs -r man 2>/dev/null | col -bx | $bat_cmd --language=man --plain --color=always --theme=OneHalfDark"

            # 修复：简化man页面解析
            man -k . 2>/dev/null | sort | \
            awk -v cyan=\$(tput setaf 6) -v blue=\$(tput setaf 4) -v res=\$(tput sgr0) -v bld=\$(tput bold) '{ \$1=cyan bld \$1; \$2=res blue \$2; } 1' | \
            fzf \
                -q "\$1" \
                --ansi \
                --tiebreak=begin \
                --prompt=' Man > ' \
                --preview-window '50%,rounded,<50(up,85%,border-bottom)' \
                --preview "\$preview_cmd" \
                --bind "enter:execute(echo {} | awk '{print \$1}' | xargs -r man)" \
                --bind "alt-c:+change-preview(echo {} | awk '{print \$1}' | xargs -I {} curl -s cht.sh/{} 2>/dev/null || echo 'cheat.sh not available')+change-prompt(' Cheat > ')" \
                --bind "alt-m:+change-preview(\$preview_cmd)+change-prompt(' Man > ')" \
                --bind "alt-t:+change-preview(echo {} | awk '{print \$1}' | xargs -r tldr --color=always 2>/dev/null || echo 'tldr not available')+change-prompt(' TLDR > ')"
        }

        # 别名 - 使用高级版本替换简单版本
        alias batman='fzf-man-widget'
        alias man-search='fman'
    else
        # 降级到简单版本（如果没有fzf）
        batman() {
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
        }

        man-search() {
            if [[ $# -eq 0 ]]; then
                echo "用法: man-search <关键词>"
                return 1
            fi
            apropos "$@"
        }
    fi
fi

# =============================================================================
# xclip 集成：复制工具集成
# =============================================================================

if command -v xclip >/dev/null 2>&1 && (command -v bat >/dev/null 2>&1 || command -v batcat >/dev/null 2>&1); then
    # 复制文件内容到剪贴板（纯文本）
    batcopy() {
        if [[ $# -eq 0 ]]; then
            echo "用法: batcopy <文件>"
            return 1
        fi

        # 使用动态检测的bat命令
        if command -v batcat >/dev/null 2>&1; then
            batcat --plain "$1" | xclip -selection clipboard
        elif command -v bat >/dev/null 2>&1; then
            bat --plain "$1" | xclip -selection clipboard
        else
            cat "$1" | xclip -selection clipboard
        fi
        echo "文件内容已复制到剪贴板"
    }

    # 从剪贴板粘贴并用 bat 显示
    batpaste() {
        # 使用动态检测的bat命令
        if command -v batcat >/dev/null 2>&1; then
            xclip -selection clipboard -o | batcat --language="${1:-txt}"
        elif command -v bat >/dev/null 2>&1; then
            xclip -selection clipboard -o | bat --language="${1:-txt}"
        else
            xclip -selection clipboard -o
        fi
    }
fi

# =============================================================================
# btop (系统监控工具) 配置
# =============================================================================

if command -v btop >/dev/null 2>&1; then
    alias top='btop'
    alias htop='btop'
fi

# =============================================================================
# 网络工具别名
# =============================================================================

# 网络诊断工具的便捷别名
if command -v mtr >/dev/null 2>&1; then
    alias mtr='mtr --show-ips'
fi

if command -v nmap >/dev/null 2>&1; then
    # 快速端口扫描
    alias nmap-quick='nmap -T4 -F'
    # 详细扫描
    alias nmap-detail='nmap -T4 -A -v'
fi

# =============================================================================
# 磁盘使用分析
# =============================================================================

if command -v ncdu >/dev/null 2>&1; then
    alias du='ncdu'
fi

# =============================================================================
# APT + fzf 集成：交互式软件包管理
# =============================================================================

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

    # APT软件包依赖查看
    apt-deps() {
        if [[ $# -eq 0 ]]; then
            echo "用法: apt-deps <软件包名>"
            echo "功能: 查看软件包依赖关系"
            return 1
        fi

        apt-cache depends "$1" | grep -E "^\s*(Depends|Recommends|Suggests):" |
        sed 's/^[[:space:]]*//' |
        fzf --preview "apt-cache show {2}" \
            --preview-window=right:60%:wrap \
            --header "依赖关系: $1"
    }

    # APT别名
    alias as='apt-search'        # APT搜索
    alias ai='apt-installed'     # 已安装软件包
    alias ainfo='apt-info'       # 软件包信息
    alias adeps='apt-deps'       # 依赖关系
fi

# =============================================================================
# 高级工具组合和实用函数
# =============================================================================

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
    if command -v fd >/dev/null 2>&1; then
        fd "$pattern" "$path" --type f -x "$bat_cmd" --color=always --style=header --line-range=:10
    fi

    echo -e "\n==> 搜索文件内容包含 '$pattern' 的文件 <=="
    if command -v rg >/dev/null 2>&1; then
        rg --color=always --line-number --no-heading "$pattern" "$path" | head -20
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

    # 代码行数统计
    if command -v rg >/dev/null 2>&1; then
        echo -e "\n代码行数统计:"
        rg --type-list | grep -E '\.(py|js|ts|go|rs|java|cpp|c|h)' | head -5 | while read -r type; do
            local ext=$(echo "$type" | cut -d: -f1)
            local count=$(fd "\.$ext$" "$dir" --type f | wc -l)
            local lines=$(fd "\.$ext$" "$dir" --type f -x wc -l | awk '{sum+=$1} END {print sum}')
            echo "$ext: $count 文件, $lines 行"
        done
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
    if command -v fd >/dev/null 2>&1; then
        fd --type f --size "+$size" . "$path" -x ls -lh {} | awk '{print $9 ": " $5}'
    else
        find "$path" -type f -size "+$size" -exec ls -lh {} \; | awk '{print $9 ": " $5}'
    fi
}

# 快速查找最近修改的文件（增强版）
find-recent() {
    local days=${1:-7}
    local path="${2:-.}"

    echo "查找最近 $days 天修改的文件..."
    if command -v fd >/dev/null 2>&1 && command -v bat >/dev/null 2>&1; then
        fd --type f --changed-within "${days}d" . "$path" -x ls -lt {} | head -20
    else
        find "$path" -type f -mtime -"$days" -exec ls -lt {} \; | head -20
    fi
}

# 端口占用检查（增强版）
port-check() {
    local port=$1
    if [[ -z "$port" ]]; then
        echo "用法: port-check <端口号>"
        return 1
    fi

    echo "检查端口 $port 的占用情况..."

    if command -v ss >/dev/null 2>&1; then
        ss -tlnp | grep ":$port "
    elif command -v netstat >/dev/null 2>&1; then
        netstat -tlnp | grep ":$port "
    else
        echo "需要安装 net-tools 或 iproute2"
        return 1
    fi
}

# 快速HTTP服务器（增强版）
serve() {
    local port=${1:-8000}
    local dir="${2:-.}"

    echo "在目录 '$dir' 启动HTTP服务器..."
    echo "端口: $port"
    echo "访问: http://localhost:$port"
    echo "按 Ctrl+C 停止服务器"

    cd "$dir" && python3 -m http.server "$port"
}

# 系统信息快速查看
sysinfo() {
    echo "==> 系统信息 <=="
    echo "主机名: $(hostname)"
    echo "系统: $(uname -s -r)"
    echo "架构: $(uname -m)"

    if command -v lsb_release >/dev/null 2>&1; then
        echo "发行版: $(lsb_release -d | cut -f2)"
    fi

    echo -e "\n==> 资源使用 <=="
    echo "内存使用: $(free -h | awk 'NR==2{printf "%.1f%%", $3*100/$2 }')"
    echo "磁盘使用: $(df -h / | awk 'NR==2{print $5}')"

    if command -v btop >/dev/null 2>&1; then
        echo -e "\n提示: 运行 'btop' 查看详细系统监控"
    fi
}

# =============================================================================
# 综合别名和快捷键配置
# =============================================================================

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

# =============================================================================
# 工具组合快捷键和提示信息
# =============================================================================

# 显示可用的工具组合命令 - 基于ADVANCED.md的全面功能
show-tools() {
    echo "==> 🚀 现代命令行工具组合 - 基于fzf ADVANCED.md全面实现 <=="
    echo
    echo "📁 文件搜索和预览:"
    echo "  fe          - 交互式文件编辑（基于basic example）"
    echo "  fo          - 用默认应用打开文件"
    echo "  vf          - 交互式文件查看（bat预览）"
    echo "  fcd         - fzf + fd: 搜索并切换目录"
    echo "  fp          - fzf: 快速跳转项目目录"
    echo "  fc          - fzf + rg: 搜索文件内容"
    echo "  fthemes     - fzf + bat: 预览 bat 主题"
    echo
    echo "📂 目录导航增强（基于basic example）:"
    echo "  fdir        - 基础目录切换"
    echo "  fdira       - 包含隐藏目录的切换"
    echo "  fdirt       - 树形预览目录切换"
    echo
    echo "🔄 动态重载和模式切换 (基于ADVANCED.md):"
    echo "  fps         - fzf动态进程管理 (CTRL-R重载)"
    echo "  ffd         - 文件/目录动态切换 (CTRL-D/CTRL-F)"
    echo "  ftm         - 单键模式切换 (CTRL-T)"
    echo "  fzf-popup   - tmux popup模式 (需要tmux 3.3+)"
    echo "  fzf-side    - tmux侧边栏模式"
    echo
    echo "� 历史命令和进程管理（基于basic example）:"
    echo "  fh          - 历史命令搜索和重复执行"
    echo "  fkill       - 交互式进程终止"
    echo "  fif         - 文件内容搜索（find in files）"
    echo "  vg          - 搜索内容并编辑（vim grep）"
    echo
    echo "�🔍 高级Ripgrep集成 (基于ADVANCED.md):"
    echo "  rfv         - Ripgrep + fzf二级过滤"
    echo "  rgi         - 交互式Ripgrep启动器"
    echo "  rg2         - 双阶段搜索 (ALT-Enter切换)"
    echo "  rgs         - Ripgrep/fzf模式切换 (CTRL-R/CTRL-F)"
    echo "  batgrep     - 传统rg + bat搜索"
    echo "  rg-fzf      - rg + fzf + bat交互式搜索"
    echo
    echo "🌿 Git对象交互 (基于ADVANCED.md):"
    echo "  gst         - Git状态交互 (CTRL-A添加/CTRL-R重置)"
    echo "  gbr         - Git分支交互 (CTRL-O切换/CTRL-D删除)"
    echo "  gco         - Git提交交互 (CTRL-S显示/CTRL-D对比)"
    echo "  gtg         - Git标签交互 (CTRL-O切换/CTRL-D删除)"
    echo "  gshow       - git + bat: 查看历史版本文件"
    echo "  gdiff       - git + bat: 增强的diff查看"
    echo "  glog        - git + fzf + bat: 交互式log查看"
    echo
    echo "📊 高级日志监控 (基于ADVANCED.md):"
    echo "  flog        - 交互式日志文件选择"
    echo "  fmlogs      - 多日志文件并行监控"
    echo "  flevel      - 日志级别过滤监控"
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
    echo "� APT软件包管理 (Ubuntu/Debian):"
    echo "  af          - 交互式搜索和安装APT软件包"
    echo "  as          - APT软件包搜索（不安装）"
    echo "  ai          - 查看已安装的软件包"
    echo "  ainfo       - 查看软件包详细信息"
    echo "  adeps       - 查看软件包依赖关系"
    echo
    echo "�📋 复制和粘贴:"
    echo "  batcopy     - bat + xclip: 复制文件内容"
    echo "  batpaste    - xclip + bat: 粘贴并高亮显示"
    echo
    echo "📖 手册和帮助:"
    echo "  batman      - man + bat: 彩色man页面"
    echo "  man-search  - man + fzf: 搜索man页面"
    echo
    echo "⌨️  高级键绑定 (在fzf中可用):"
    echo "  CTRL-/      - 切换预览窗口"
    echo "  CTRL-U/D    - 预览窗口上下翻页"
    echo "  ALT-UP/DOWN - 预览内容上下滚动"
    echo "  CTRL-A/X    - 全选/取消全选"
    echo "  CTRL-T      - 切换选择"
    echo "  CTRL-S      - 切换排序"
    echo "  CTRL-R      - 重载数据"
    echo
    echo "🎨 tmux集成功能:"
    echo "  tm          - tmux会话管理（基于basic example）"
    echo "  fs          - tmux会话切换"
    echo "  ftpane      - tmux窗格切换"
    echo "  fzf-tmux-center  - 中央popup (需要tmux 3.3+)"
    echo "  fzf-tmux-right   - 右侧popup"
    echo "  fzf-tmux-bottom  - 底部popup"
    echo "  fzf-tmux-top     - 顶部popup"
    echo
    echo "💡 提示: 运行 'show-tools' 随时查看此帮助信息"
    echo "📚 基于官方fzf ADVANCED.md文档实现的全面功能集"
}

# 首次加载时显示提示
if [[ -z "$SHELL_TOOLS_LOADED" ]]; then
    export SHELL_TOOLS_LOADED=1
    echo "🚀 现代命令行工具已加载！基于fzf ADVANCED.md全面实现"
    echo "💡 运行 'show-tools' 查看所有可用的高级功能"
    echo "📚 包含动态重载、模式切换、Git集成、日志监控等高级特性"
fi
'''

    try:
        with open(config_path, 'w') as f:
            f.write(config_content)

        log_success(f"Shell工具配置文件已生成: {config_path}")
        return True

    except Exception as e:
        log_error(f"生成Shell工具配置文件失败: {str(e)}")
        return False

def update_zshrc_for_shell_tools():
    """
    更新.zshrc文件以引用Shell工具配置

    Returns:
        bool: 更新是否成功
    """
    zshrc_path = Path.home() / ".zshrc"
    config_source_line = "# Shell Tools Configuration - Auto-generated by shell-tools-config-generator.py"
    source_line = "[[ -f ~/.shell-tools-config.zsh ]] && source ~/.shell-tools-config.zsh"

    if not zshrc_path.exists():
        log_warn(".zshrc文件不存在，创建新文件")
        with open(zshrc_path, 'w') as f:
            f.write(f"{config_source_line}\n{source_line}\n")
        return True

    try:
        with open(zshrc_path, 'r') as f:
            content = f.read()

        # 检查是否已经包含Shell工具配置引用
        if source_line in content:
            log_info("Shell工具配置引用已存在于.zshrc中")
            return True

        # 添加Shell工具配置引用
        with open(zshrc_path, 'a') as f:
            f.write(f"\n{config_source_line}\n{source_line}\n")

        log_success("已更新.zshrc文件以引用Shell工具配置")
        return True

    except Exception as e:
        log_error(f"更新.zshrc文件失败: {str(e)}")
        return False

def main():
    """主函数"""
    show_header("Shell工具配置生成器", "1.0", "生成fd、fzf等现代shell工具的最佳实践配置")

    log_info("开始生成Shell工具配置...")

    # 生成Shell工具配置文件
    if not generate_shell_tools_config():
        log_error("Shell工具配置文件生成失败")
        return False

    # 更新.zshrc文件
    if not update_zshrc_for_shell_tools():
        log_error(".zshrc文件更新失败")
        return False

    log_success("Shell工具配置生成完成！")
    log_info("请运行 'source ~/.zshrc' 或重新启动终端以应用配置")

    return True

if __name__ == "__main__":
    main()
