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

if command -v bat >/dev/null 2>&1; then
    # bat 环境变量配置
    export BAT_STYLE="numbers,changes,header,grid"
    export BAT_THEME="OneHalfDark"
    export BAT_PAGER="less -RFK"

    # 基础别名
    alias cat='bat --paging=never'
    alias less='bat --paging=always'
    alias more='bat --paging=always'

    # 实用别名
    alias batl='bat --paging=always'  # 强制分页
    alias batn='bat --style=plain'    # 纯文本模式，无装饰
    alias batp='bat --plain'          # 纯文本模式（简写）
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
    if command -v bat >/dev/null 2>&1; then
        # 搜索并用 bat 查看所有匹配的文件
        fdbat() {
            if [[ $# -eq 0 ]]; then
                echo "用法: fdbat <搜索模式> [路径]"
                echo "示例: fdbat '\\.py$' src/"
                return 1
            fi
            fd "$@" --type f -X bat
        }

        # 搜索并预览文件内容
        fdpreview() {
            if [[ $# -eq 0 ]]; then
                echo "用法: fdpreview <搜索模式> [路径]"
                return 1
            fi
            fd "$@" --type f -x bat --color=always --style=header,grid --line-range=:50
        }
    fi
fi

# =============================================================================
# fzf (模糊查找工具) 高级配置与集成
# =============================================================================

if command -v fzf >/dev/null 2>&1; then
    # fzf 核心配置 - 优化的默认选项
    export FZF_DEFAULT_OPTS="--height 60% --layout=reverse --border --inline-info --preview-window=right:50%:wrap --bind='ctrl-/:toggle-preview'"

    # 使用 fd 作为 fzf 的默认搜索命令（如果可用）
    if command -v fd >/dev/null 2>&1; then
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git --exclude node_modules'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git --exclude node_modules'
    fi

    # fzf + bat 集成：带语法高亮的文件预览
    if command -v bat >/dev/null 2>&1; then
        export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}'"

        # 高级文件搜索和编辑
        fzf-edit() {
            local file
            file=$(fzf --preview 'bat --color=always --style=numbers,changes --line-range=:500 {}' \
                      --preview-window=right:60%:wrap \
                      --bind='ctrl-/:toggle-preview,ctrl-u:preview-page-up,ctrl-d:preview-page-down')
            if [[ -n "$file" ]]; then
                ${EDITOR:-vim} "$file"
            fi
        }

        # 搜索文件内容并预览
        fzf-content() {
            if command -v rg >/dev/null 2>&1; then
                rg --color=always --line-number --no-heading --smart-case "${*:-}" |
                fzf --ansi \
                    --color "hl:-1:underline,hl+:-1:underline:reverse" \
                    --delimiter : \
                    --preview 'bat --color=always {1} --highlight-line {2}' \
                    --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
                    --bind 'enter:become(vim {1} +{2})'
            else
                echo "需要安装 ripgrep (rg) 来使用此功能"
            fi
        }

        # 查看 bat 主题预览
        fzf-bat-themes() {
            bat --list-themes | fzf --preview="bat --theme={} --color=always ~/.bashrc || bat --theme={} --color=always /etc/passwd"
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

    # 实用别名
    alias fe='fzf-edit'           # 搜索并编辑文件
    alias fcd='fzf-cd'            # 搜索并切换目录
    alias fp='fzf-project'        # 快速跳转项目
    alias fc='fzf-content'        # 搜索文件内容
    alias fthemes='fzf-bat-themes' # 预览 bat 主题
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

    # ripgrep + bat 集成：batgrep 功能
    if command -v bat >/dev/null 2>&1; then
        # 搜索并用 bat 高亮显示结果
        batgrep() {
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
                bat --color=always --highlight-line="$line" --line-range="$((line-3)):$((line+3))" "$file" 2>/dev/null || echo "$content"
                echo
            done
        }

        # 交互式搜索：搜索后可以选择文件查看
        rg-fzf() {
            if [[ $# -eq 0 ]]; then
                echo "用法: rg-fzf <搜索模式>"
                return 1
            fi

            rg --color=always --line-number --no-heading --smart-case "$@" |
            fzf --ansi \
                --color "hl:-1:underline,hl+:-1:underline:reverse" \
                --delimiter : \
                --preview 'bat --color=always {1} --highlight-line {2} --line-range {2}:' \
                --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
                --bind 'enter:become(bat --paging=always {1} --highlight-line {2})'
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

if command -v git >/dev/null 2>&1 && command -v bat >/dev/null 2>&1; then
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
        git show "$ref_file" | bat -l "$file_ext"
    }

    # git diff 与 bat 集成：batdiff 功能
    batdiff() {
        git diff --name-only --relative --diff-filter=d "$@" |
        while read -r file; do
            echo "==> $file <=="
            git diff "$@" -- "$file" | bat --language=diff
            echo
        done
    }

    # 增强的 git log 查看
    git-log-bat() {
        git log --oneline --color=always "$@" |
        fzf --ansi --preview 'git show --color=always {1} | bat --language=diff' \
            --preview-window=right:60%:wrap \
            --bind 'enter:become(git show {1} | bat --language=diff --paging=always)'
    }

    # Git 别名
    alias gshow='git-show-bat'
    alias gdiff='batdiff'
    alias glog='git-log-bat'
fi

# =============================================================================
# tail + bat 集成：日志监控与语法高亮
# =============================================================================

if command -v bat >/dev/null 2>&1; then
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

        tail -f "$file" | bat --paging=never -l "$syntax"
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
                tail -f "$file" | bat --paging=never -l log &
            fi
        done
        wait
    }

    # 常用日志监控别名
    alias tailsys='tailbat /var/log/syslog log'
    alias tailauth='tailbat /var/log/auth.log log'
    alias taildmesg='dmesg -w | bat --paging=never -l log'
fi

# =============================================================================
# man + bat 集成：彩色 man 页面
# =============================================================================

if command -v bat >/dev/null 2>&1; then
    # 设置 MANPAGER 使用 bat 作为 man 页面的分页器
    export MANPAGER="sh -c 'awk '\''{gsub(/\\x1B\\[[0-9;]*m/, \"\", \\$0); gsub(/.\\x08/, \"\", \\$0); print}'\'' | bat -p -lman'"

    # 备用 man 函数（如果上面的不工作）
    batman() {
        if [[ $# -eq 0 ]]; then
            echo "用法: batman <命令名>"
            return 1
        fi
        man "$@" | bat -p -lman
    }

    # man 页面搜索
    man-search() {
        if [[ $# -eq 0 ]]; then
            echo "用法: man-search <关键词>"
            return 1
        fi
        apropos "$@" | fzf --preview 'man {1} | bat -p -lman' --preview-window=right:70%:wrap
    }
fi

# =============================================================================
# xclip 集成：复制工具集成
# =============================================================================

if command -v xclip >/dev/null 2>&1 && command -v bat >/dev/null 2>&1; then
    # 复制文件内容到剪贴板（纯文本）
    batcopy() {
        if [[ $# -eq 0 ]]; then
            echo "用法: batcopy <文件>"
            return 1
        fi
        bat --plain "$1" | xclip -selection clipboard
        echo "文件内容已复制到剪贴板"
    }

    # 从剪贴板粘贴并用 bat 显示
    batpaste() {
        xclip -selection clipboard -o | bat --language="${1:-txt}"
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
# 高级工具组合和实用函数
# =============================================================================

# 综合搜索函数：结合 fd、rg、fzf、bat
search-all() {
    if [[ $# -eq 0 ]]; then
        echo "用法: search-all <搜索模式> [路径]"
        echo "功能: 同时搜索文件名和文件内容"
        return 1
    fi

    local pattern="$1"
    local path="${2:-.}"

    echo "==> 搜索文件名包含 '$pattern' 的文件 <=="
    if command -v fd >/dev/null 2>&1 && command -v bat >/dev/null 2>&1; then
        fd "$pattern" "$path" --type f -x bat --color=always --style=header --line-range=:10
    fi

    echo -e "\n==> 搜索文件内容包含 '$pattern' 的文件 <=="
    if command -v rg >/dev/null 2>&1 && command -v bat >/dev/null 2>&1; then
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

# 显示可用的工具组合命令
show-tools() {
    echo "==> 可用的现代命令行工具组合 <=="
    echo
    echo "文件搜索和预览:"
    echo "  fe          - fzf + bat: 搜索并编辑文件"
    echo "  fcd         - fzf + fd: 搜索并切换目录"
    echo "  fp          - fzf: 快速跳转项目目录"
    echo "  fc          - fzf + rg: 搜索文件内容"
    echo "  fthemes     - fzf + bat: 预览 bat 主题"
    echo
    echo "搜索和内容查看:"
    echo "  batgrep     - rg + bat: 搜索并高亮显示"
    echo "  rg-fzf      - rg + fzf + bat: 交互式内容搜索"
    echo "  fdbat       - fd + bat: 批量查看搜索结果"
    echo "  fdpreview   - fd + bat: 搜索并预览文件"
    echo
    echo "Git 集成:"
    echo "  gshow       - git + bat: 查看历史版本文件"
    echo "  gdiff       - git + bat: 增强的 diff 查看"
    echo "  glog        - git + fzf + bat: 交互式 log 查看"
    echo
    echo "日志监控:"
    echo "  tailbat     - tail + bat: 实时日志监控"
    echo "  tailsys     - 系统日志监控"
    echo "  tailauth    - 认证日志监控"
    echo
    echo "系统分析:"
    echo "  search      - 综合搜索（文件名+内容）"
    echo "  analyze     - 项目结构分析"
    echo "  large       - 查找大文件"
    echo "  recent      - 查找最近修改的文件"
    echo "  port        - 端口占用检查"
    echo "  info        - 系统信息概览"
    echo
    echo "复制和粘贴:"
    echo "  batcopy     - bat + xclip: 复制文件内容"
    echo "  batpaste    - xclip + bat: 粘贴并高亮显示"
    echo
    echo "手册和帮助:"
    echo "  batman      - man + bat: 彩色 man 页面"
    echo "  man-search  - man + fzf: 搜索 man 页面"
    echo
    echo "提示: 运行 'show-tools' 随时查看此帮助信息"
}

# 首次加载时显示提示
if [[ -z "$SHELL_TOOLS_LOADED" ]]; then
    export SHELL_TOOLS_LOADED=1
    echo "🚀 现代命令行工具已加载！运行 'show-tools' 查看可用命令"
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
