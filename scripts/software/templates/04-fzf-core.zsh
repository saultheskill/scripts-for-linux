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
        --color='fg:#d0d0d0,bg:#121212,hl:#5f87af'
        --color='fg+:#d0d0d0,bg+:#262626,hl+:#5fd7ff'
        --color='info:#afaf87,prompt:#d7005f,pointer:#af5fff'
        --color='marker:#87ff00,spinner:#af5fff,header:#87afaf'
        --color='border:#585858,preview-bg:#121212'
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
