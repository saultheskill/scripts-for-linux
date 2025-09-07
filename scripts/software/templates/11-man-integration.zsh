# man页面集成（修复batman搜索功能）

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
