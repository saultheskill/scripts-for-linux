# fzf (模糊查找工具) 核心配置与显示设置

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
        --color='fg:#CBE0F0,bg:#011628,hl:#B388FF'
        --color='fg+:#CBE0F0,bg+:#143652,hl+:#B388FF'
        --color='info:#06BCE4,prompt:#2CF9ED,pointer:#2CF9ED'
        --color='marker:#A4E400,spinner:#FF8A65,header:#2CF9ED'
        --color='border:#06BCE4,preview-bg:#011628,preview-border:#B388FF'
        --prompt='🔍 '
        --pointer='▶ '
        --marker='✓ '
    "

    # tmux 集成配置 - 基于官方ADVANCED.md的tmux popup功能
    if [[ -n "${TMUX:-}" ]] && command -v tmux >/dev/null 2>&1; then
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

    # 确定使用的工具命令
    if command -v batcat >/dev/null 2>&1; then
        bat_cmd='batcat'
    elif command -v bat >/dev/null 2>&1; then
        bat_cmd='bat'
    else
        bat_cmd='cat'
    fi

    # 优先检查实际的二进制文件，而不是别名
    if command -v fdfind >/dev/null 2>&1; then
        fd_cmd='fdfind'
    elif command -v fd >/dev/null 2>&1; then
        # 检查是否是真正的 fd 二进制文件，而不是别名
        if [[ "$(command -v fd)" != *"alias"* ]]; then
            fd_cmd='fd'
        else
            fd_cmd='fdfind'
        fi
    else
        fd_cmd='find'
    fi

    # 增强的文件搜索配置
    if [[ "$fd_cmd" != "find" ]]; then
        export FZF_DEFAULT_COMMAND="$fd_cmd --hidden --strip-cwd-prefix --exclude .git"
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_ALT_C_COMMAND="$fd_cmd --type=d --hidden --strip-cwd-prefix --exclude .git"
    else
        export FZF_DEFAULT_COMMAND="find . -type f -not -path '*/\.git/*'"
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_ALT_C_COMMAND="find . -type d -not -path '*/\.git/*'"
    fi

    # CTRL-T 和 ALT-C 的预览配置
    export FZF_CTRL_T_OPTS="--preview '$bat_cmd --color=always --style=numbers --line-range=:500 {}' --header '📁 选择文件 | CTRL-/: 切换预览'"

    if command -v eza >/dev/null 2>&1; then
        export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always --icons=auto --level=2 {} | head -50' --header '📁 选择目录 | CTRL-/: 切换预览'"
    elif command -v exa >/dev/null 2>&1; then
        export FZF_ALT_C_OPTS="--preview 'exa --tree --color=always --level=2 {} | head -50' --header '📁 选择目录 | CTRL-/: 切换预览'"
    else
        export FZF_ALT_C_OPTS="--preview 'ls -la {} | head -20' --header '📁 选择目录 | CTRL-/: 切换预览'"
    fi

    # 自定义补全预览函数
    _fzf_compgen_path() {
        if [[ "$fd_cmd" != "find" ]]; then
            $fd_cmd --hidden --exclude .git . "$1"
        else
            find "$1" -type f -not -path '*/\.git/*'
        fi
    }

    _fzf_compgen_dir() {
        if [[ "$fd_cmd" != "find" ]]; then
            $fd_cmd --type=d --hidden --exclude .git . "$1"
        else
            find "$1" -type d -not -path '*/\.git/*'
        fi
    }

    # 增强的命令特定预览
    _fzf_comprun() {
        local command=$1
        shift

        case "$command" in
            cd)           fzf --preview "
                            if command -v eza >/dev/null 2>&1; then
                                eza --tree --color=always --icons=auto --level=2 {} | head -50
                            elif command -v exa >/dev/null 2>&1; then
                                exa --tree --color=always --level=2 {} | head -50
                            else
                                ls -la {} | head -20
                            fi
                          " --header '📁 选择目录' "$@" ;;
            export|unset) fzf --preview "eval 'echo \\\$'{}" --header '🔧 环境变量' "$@" ;;
            ssh)          fzf --preview 'dig {}' --header '🌐 SSH 连接' "$@" ;;
            *)            fzf --preview "$bat_cmd --color=always --style=numbers --line-range=:500 {}" --header '📄 选择文件' "$@" ;;
        esac
    }

    # 确保环境变量在键绑定加载前设置
    echo "🔧 FZF 配置已加载"
    echo "   CTRL-T: 文件选择 (使用 $fd_cmd)"
    echo "   ALT-C: 目录选择"
    echo "   CTRL-R: 历史搜索"

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
