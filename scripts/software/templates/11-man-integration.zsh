# man页面集成（修复batman搜索功能）

if command -v bat >/dev/null 2>&1 || command -v batcat >/dev/null 2>&1; then
    # 设置 MANPAGER 使用 bat 作为 man 页面的分页器 - 修复兼容性
    if command -v batcat >/dev/null 2>&1; then
        export MANPAGER="sh -c 'col -bx | batcat -l man -p'"
    elif command -v bat >/dev/null 2>&1; then
        export MANPAGER="sh -c 'col -bx | bat -l man -p'"
    fi

    # 快速 man 页面搜索 - 简化版的 batman
    fman() {
        if command -v fzf >/dev/null 2>&1; then
            # 确定使用的 bat 命令
            local bat_cmd
            if command -v batcat >/dev/null 2>&1; then
                bat_cmd='batcat'
            elif command -v bat >/dev/null 2>&1; then
                bat_cmd='bat'
            else
                bat_cmd='cat'
            fi

            # 简化的 man 页面选择
            man -k . 2>/dev/null | \
                fzf \
                    --query="$1" \
                    --prompt="🔍 " \
                    --header="📖 快速 Man 搜索 | ENTER: 打开手册页" \
                    --preview="
                        cmd=\$(echo {} | awk '{print \$1}')
                        section=\$(echo {} | sed 's/.*(\([^)]*\)).*/\1/')

                        echo '📖 '\$cmd'('\$section')'
                        echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
                        if man \$section \$cmd >/dev/null 2>&1; then
                            man \$section \$cmd 2>/dev/null | col -bx | $bat_cmd --language=man --style=header --color=always --line-range=:25 --wrap=never 2>/dev/null
                        else
                            echo '❌ Manual page not available'
                        fi
                    " \
                    --preview-window="right,50%" \
                    --bind="enter:execute(
                        cmd=\$(echo {} | awk '{print \$1}')
                        section=\$(echo {} | sed 's/.*(\([^)]*\)).*/\1/')
                        man \$section \$cmd
                    )"
        else
            echo "用法: fman [关键词]"
            echo "💡 需要安装 fzf 来使用此功能"
            if [[ $# -gt 0 ]]; then
                apropos "$@"
            fi
        fi
    }

    # 高级 batman 命令 - 基于 CTRL+T 风格的 fzf 集成
    batman() {
        if command -v fzf >/dev/null 2>&1; then
            # 确定使用的 bat 命令
            local bat_cmd
            if command -v batcat >/dev/null 2>&1; then
                bat_cmd='batcat'
            elif command -v bat >/dev/null 2>&1; then
                bat_cmd='bat'
            else
                echo "错误：未找到 bat 工具，请先安装"
                return 1
            fi

            # 美化主题配置（与 CTRL+T 保持一致）
            local fg="#CBE0F0"
            local bg="#011628"
            local bg_highlight="#143652"
            local purple="#B388FF"
            local blue="#06BCE4"
            local cyan="#2CF9ED"
            local green="#A4E400"
            local orange="#FF8A65"

            # 生成 man 页面列表（使用简化的解析方法）
            local man_list
            man_list=$(man -k . 2>/dev/null | \
                sed 's/^\([^(]*\)(\([^)]*\)) *- *\(.*\)/\1 (\2) \3/' | \
                awk '{
                    cmd = $1
                    section = $2
                    desc = ""
                    for(i=3; i<=NF; i++) desc = desc " " $i
                    gsub(/^[ \t]+/, "", desc)
                    printf "%-25s %s%s\n", cmd, section, desc
                }' | sort -k1,1)

            if [[ -z "$man_list" ]]; then
                echo "错误：无法获取 man 页面列表"
                return 1
            fi

            # 使用 fzf 进行选择，参考 CTRL+T 的配置风格
            local selected
            selected=$(echo "$man_list" | \
                fzf \
                    --height=80% \
                    --layout=reverse \
                    --border=rounded \
                    --margin=1 \
                    --padding=1 \
                    --info=inline \
                    --prompt="📖 " \
                    --pointer="▶ " \
                    --marker="✓ " \
                    --color="fg:${fg},bg:${bg},hl:${purple},fg+:${fg},bg+:${bg_highlight},hl+:${purple}" \
                    --color="info:${blue},prompt:${cyan},pointer:${cyan},marker:${green},spinner:${orange},header:${cyan}" \
                    --color="border:${blue},preview-border:${purple}" \
                    --query="$1" \
                    --ansi \
                    --tiebreak=begin \
                    --preview-window="right,55%,border-left" \
                    --preview="
                        cmd=\$(echo {} | awk '{print \$1}')
                        section=\$(echo {} | sed 's/.*(\([^)]*\)).*/\1/')
                        desc=\$(echo {} | sed 's/^[^)]*) *//')

                        # 头部信息
                        echo '╭─────────────────────────────────────────────────────────────╮'
                        printf '│ 📖 %-55s  │\n' \"\$cmd(\$section)\"
                        echo '├─────────────────────────────────────────────────────────────┤'
                        printf '│ 📊 Section: %-47s │\n' \"\$section\"
                        printf '│ 📝 Description: %-43s │\n' \"\$(echo \$desc | cut -c1-43)\"
                        echo '╰─────────────────────────────────────────────────────────────╯'
                        echo

                        # Man 页面内容预览
                        if man \$section \$cmd >/dev/null 2>&1; then
                            echo '📄 Manual Page Preview:'
                            echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
                            man \$section \$cmd 2>/dev/null | col -bx | $bat_cmd --language=man --style=header,grid --color=always --line-range=:40 --wrap=never 2>/dev/null
                        else
                            echo '❌ Manual page not available for '\$cmd'('\$section')'
                            echo
                            echo '💡 This might be because:'
                            echo '   • The manual page is not installed'
                            echo '   • The section number is incorrect'
                            echo '   • The command name has changed'
                        fi
                    " \
                    --bind="ctrl-/:change-preview-window(down,60%,border-top|right,55%,border-left|hidden)" \
                    --bind="ctrl-y:execute-silent(echo {} | awk '{print \$1}' | pbcopy)" \
                    --bind="alt-a:select-all" \
                    --bind="alt-d:deselect-all" \
                    --bind="ctrl-r:reload(man -k . 2>/dev/null | awk '{match(\$0, /^([^(]+)\(([^)]+)\)(.*)/, arr); if (arr[1] && arr[2] && arr[3]) {cmd = arr[1]; section = arr[2]; desc = arr[3]; gsub(/^[ \t-]+/, \"\", desc); printf \"%-25s (%s) %s\\n\", cmd, section, desc}}' | sort -k1,1)" \
                    --header="📖 Man Pages | ENTER: 打开 | CTRL-/: 切换预览 | CTRL-Y: 复制命令名 | CTRL-R: 刷新")

            if [[ -n "$selected" ]]; then
                # 提取命令名和章节
                local cmd section
                cmd=$(echo "$selected" | awk '{print $1}')
                section=$(echo "$selected" | sed 's/.*(\([^)]*\)).*/\1/')

                echo "📖 打开手册页: $cmd($section)"
                man "$section" "$cmd"
            fi
        else
            # 降级到简单版本（如果没有 fzf）
            if [[ $# -eq 0 ]]; then
                echo "用法: batman [搜索关键词]"
                echo "💡 安装 fzf 以获得完整的交互式体验"
                return 1
            fi

            # 使用动态检测的 bat 命令
            if command -v batcat >/dev/null 2>&1; then
                man "$@" | batcat -p -l man
            elif command -v bat >/dev/null 2>&1; then
                man "$@" | bat -p -l man
            else
                man "$@"
            fi
        fi
    }

    # man 页面搜索函数
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

    # 按章节浏览 man 页面
    man-section() {
        local section="${1:-1}"
        if command -v fzf >/dev/null 2>&1; then
            # 确定使用的 bat 命令
            local bat_cmd
            if command -v batcat >/dev/null 2>&1; then
                bat_cmd='batcat'
            elif command -v bat >/dev/null 2>&1; then
                bat_cmd='bat'
            else
                bat_cmd='cat'
            fi

            man -k . 2>/dev/null | grep "($section)" | \
                fzf \
                    --prompt="📖 Section $section > " \
                    --header="📖 Man Pages Section $section | ENTER: 打开手册页" \
                    --preview="
                        cmd=\$(echo {} | awk '{print \$1}')

                        echo '📖 '\$cmd'($section) - Section $section'
                        echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
                        if man $section \$cmd >/dev/null 2>&1; then
                            man $section \$cmd 2>/dev/null | col -bx | $bat_cmd --language=man --style=header --color=always --line-range=:35 --wrap=never 2>/dev/null
                        else
                            echo '❌ Manual page not available for '\$cmd' in section $section'
                        fi
                    " \
                    --preview-window="right,50%" \
                    --bind="enter:execute(
                        cmd=\$(echo {} | awk '{print \$1}')
                        man $section \$cmd
                    )"
        else
            echo "用法: man-section [章节号]"
            echo "💡 需要安装 fzf 来使用此功能"
            man -k . | grep "($section)"
        fi
    }

    # 显示 man 页面章节说明
    man-help() {
        echo "📖 Man 页面章节说明:"
        echo "  1 - 用户命令 (User Commands)"
        echo "  2 - 系统调用 (System Calls)"
        echo "  3 - 库函数 (Library Functions)"
        echo "  4 - 设备文件 (Device Files)"
        echo "  5 - 配置文件 (Configuration Files)"
        echo "  6 - 游戏 (Games)"
        echo "  7 - 杂项 (Miscellaneous)"
        echo "  8 - 系统管理 (System Administration)"
        echo
        echo "🚀 可用命令:"
        echo "  batman        - 交互式 man 页面浏览器"
        echo "  fman [关键词] - 快速 man 页面搜索"
        echo "  man-section N - 浏览指定章节的 man 页面"
        echo "  man-search    - 搜索 man 页面"
        echo "  man-help      - 显示此帮助信息"
    }

    # 别名定义
    alias manf='fman'           # fman 的简短别名
    alias mans='man-search'     # man-search 的简短别名
    alias manh='man-help'       # man-help 的简短别名

    echo "📖 Man 页面集成已加载"
    echo "   主要命令: batman, fman, man-section"
    echo "   运行 'man-help' 查看完整功能列表"
fi
