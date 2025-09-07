# =============================================================================
# Git + FZF + Bat 集成功能 - 美化版
# =============================================================================
#
# 功能说明：
# - 提供交互式的 Git 操作界面，使用 fzf 进行选择和预览
# - 使用 bat 进行语法高亮和美化显示
# - 覆盖 Oh My Zsh 的部分 Git 别名，提供增强功能
#
# 别名覆盖策略：
# - gco:  git checkout -> 交互式分支切换
# - glog: git log --oneline --decorate --graph -> 交互式提交历史浏览
# - gst:  git status -> 交互式文件状态管理
# - gbl:  git blame -w -> 交互式 blame 浏览
#
# 原始功能保留：
# - 所有被覆盖的原始功能都通过 *-orig 别名保留
# - 例如：gco-orig, glog-orig, gst-orig, gbl-orig
#
# =============================================================================

if command -v git >/dev/null 2>&1 && command -v fzf >/dev/null 2>&1; then
    # 确定使用的bat命令
    if command -v batcat >/dev/null 2>&1; then
        bat_cmd='batcat'
    elif command -v bat >/dev/null 2>&1; then
        bat_cmd='bat'
    else
        bat_cmd='cat'
    fi

    # 美化主题配置
    fg="#CBE0F0"
    bg="#011628"
    bg_highlight="#143652"
    purple="#B388FF"
    blue="#06BCE4"
    cyan="#2CF9ED"
    green="#A4E400"
    orange="#FF8A65"

    # 通用 fzf 配置
    fzf_git_opts="--height 75% --layout reverse --border rounded
        --color fg:${fg},bg:${bg},hl:${purple},fg+:${fg},bg+:${bg_highlight},hl+:${purple}
        --color info:${blue},prompt:${cyan},pointer:${cyan},marker:${green},spinner:${orange},header:${cyan}
        --color border:${blue},preview-border:${purple}
        --preview-window right,50%,border-left
        --bind ctrl-/:change-preview-window(down,60%,border-top|right,50%,border-left|hidden)
        --bind ctrl-y:execute-silent(echo {} | pbcopy)
        --prompt 🔍\  --pointer ▶\  --marker ✓\ "

    # Git分支选择和切换 - 美化版
    _git_checkout_interactive() {
        local branch
        branch=$(git branch -a --color=always | grep -v '/HEAD\s' | \
        fzf --ansi $fzf_git_opts \
            --preview "
                branch=\$(echo {} | sed 's/^[* ] //' | sed 's/^remotes\///')
                echo '🌿 分支: '\$branch
                echo '📊 统计: '$(git rev-list --count \$branch 2>/dev/null || echo '0')' 个提交'
                echo '🕒 最后提交: '$(git log -1 --format='%cr' \$branch 2>/dev/null || echo 'N/A')
                echo '👤 作者: '$(git log -1 --format='%an' \$branch 2>/dev/null || echo 'N/A')
                echo
                echo '📝 最近提交:'
                git log --oneline --graph --color=always --date=short \
                    --pretty='format:%C(yellow)%h%C(reset) %C(blue)%ad%C(reset) %s%C(auto)%d' \
                    \$branch | head -10
            " \
            --header '🌿 选择分支切换 | CTRL-/: 切换预览 | CTRL-Y: 复制分支名')

        if [[ -n "$branch" ]]; then
            local clean_branch=$(echo "$branch" | sed 's/^[* ] //' | sed 's/^remotes\///' | awk '{print $1}')
            git checkout "$clean_branch"
        fi
    }

    # Git提交历史浏览 - 美化版
    _git_log_interactive() {
        git log --graph --color=always \
            --format="%C(green)%C(bold)%cd %C(auto)%h%d %s %C(blue)(%an)" --date=short "$@" | \
        fzf --ansi --no-sort --reverse --tiebreak=index $fzf_git_opts \
            --bind=ctrl-s:toggle-sort \
            --preview "
                hash=\$(echo {} | grep -o '[a-f0-9]\{7,\}' | head -1)
                if [[ -n \$hash ]]; then
                    echo '📝 提交: '\$hash
                    echo '👤 作者: '$(git show -s --format='%an <%ae>' \$hash)
                    echo '🕒 时间: '$(git show -s --format='%cd' --date=format:'%Y-%m-%d %H:%M:%S' \$hash)
                    echo '📊 统计: '$(git show --stat \$hash | tail -1)
                    echo
                    echo '💬 提交信息:'
                    git show -s --format='%B' \$hash | head -5
                    echo
                    echo '🔄 文件变更:'
                    git show --color=always --stat \$hash
                fi
            " \
            --header '📝 Git 提交历史 | CTRL-S: 排序 | ENTER: 查看详情 | CTRL-/: 切换预览' \
            --bind "ctrl-m:execute:
                (grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --color=always % | $bat_cmd -l diff') << 'FZF-EOF'
                {}
FZF-EOF"
    }

    # Git文件状态查看和操作 - 美化版
    _git_status_interactive() {
        git status --porcelain | \
        fzf --multi --ansi $fzf_git_opts \
            --preview "
                file=\$(echo {} | awk '{print \$2}')
                status=\$(echo {} | cut -c1-2)
                echo '📄 文件: '\$file
                echo '📊 状态: '\$status
                case \$status in
                    'M '*) echo '🔄 已修改 (工作区)' ;;
                    ' M') echo '🔄 已修改 (暂存区)' ;;
                    'A '*) echo '➕ 新增文件' ;;
                    'D '*) echo '❌ 已删除' ;;
                    'R '*) echo '📝 重命名' ;;
                    'C '*) echo '📋 复制' ;;
                    '??') echo '❓ 未跟踪' ;;
                    *) echo '🔍 其他状态' ;;
                esac
                echo
                if [[ -f \$file ]]; then
                    echo '📝 文件内容:'
                    $bat_cmd --color=always --style=numbers --line-range=:50 \$file 2>/dev/null || cat \$file
                    echo
                    echo '🔄 差异:'
                    git diff --color=always \$file 2>/dev/null || echo '  无差异'
                else
                    echo '❌ 文件不存在或已删除'
                fi
            " \
            --header '📊 Git 文件状态 | TAB: 多选 | ENTER: add | CTRL-R: reset | CTRL-/: 切换预览' \
            --bind 'enter:execute-silent(git add {2})+reload(git status --porcelain)' \
            --bind 'ctrl-r:execute-silent(git reset {2})+reload(git status --porcelain)'
    }

    # Git stash管理
    gstash() {
        local stash
        stash=$(git stash list | fzf --preview 'git stash show -p {1}' | cut -d: -f1)
        if [[ -n "$stash" ]]; then
            echo "选择操作:"
            echo "1) apply"
            echo "2) pop"
            echo "3) drop"
            echo "4) show"
            read -k1 choice
            echo
            case $choice in
                1) git stash apply "$stash" ;;
                2) git stash pop "$stash" ;;
                3) git stash drop "$stash" ;;
                4) git stash show -p "$stash" | $bat_cmd -l diff ;;
                *) echo "无效选择" ;;
            esac
        fi
    }

    # Git远程分支管理
    gremote() {
        local branch
        branch=$(git branch -r | grep -v HEAD | fzf --preview 'git log --oneline --graph --color=always {1}')
        if [[ -n "$branch" ]]; then
            local local_branch=$(echo "$branch" | sed 's|origin/||')
            git checkout -b "$local_branch" "$branch"
        fi
    }

    # Git文件历史 - 美化版
    gfh() {
        local file="$1"
        if [[ -z "$file" ]]; then
            file=$(git ls-files | \
            fzf $fzf_git_opts \
                --preview "
                    echo '📄 文件: {}'
                    echo '📏 大小: '$(ls -lh {} 2>/dev/null | awk '{print \$5}' || echo 'N/A')
                    echo '🕒 修改: '$(stat -c '%y' {} 2>/dev/null | cut -d. -f1 || echo 'N/A')
                    echo
                    $bat_cmd --color=always --style=numbers --line-range=:30 {}
                " \
                --header '📄 选择文件查看历史 | CTRL-/: 切换预览')
        fi

        if [[ -n "$file" ]]; then
            git log --follow --patch --color=always --date=short \
                --pretty='format:%C(green)%cd %C(yellow)%h %C(blue)(%an) %C(reset)%s' -- "$file" | \
            fzf --ansi --no-sort --reverse --tiebreak=index $fzf_git_opts \
                --preview "
                    echo '📄 文件历史: $file'
                    echo '📊 提交统计: '$(git log --oneline -- '$file' | wc -l)' 个提交'
                    echo
                    hash=\$(echo {} | grep -o '[a-f0-9]\{7,\}' | head -1)
                    if [[ -n \$hash ]]; then
                        echo '📝 提交详情:'
                        git show --color=always --stat \$hash -- '$file'
                    fi
                " \
                --header "📜 $file 的提交历史 | CTRL-/: 切换预览"
        fi
    }

    # Git blame浏览
    gblame() {
        local file="$1"
        if [[ -z "$file" ]]; then
            file=$(git ls-files | fzf --preview "$bat_cmd --color=always {}")
        fi

        if [[ -n "$file" ]]; then
            git blame --color-lines "$file" | \
            fzf --ansi --preview "echo {} | cut -d' ' -f1 | xargs git show --color=always"
        fi
    }

    # Git差异查看 - 美化版
    gdiff() {
        local file
        file=$(git diff --name-only | \
        fzf $fzf_git_opts \
            --preview "
                echo '📄 文件: {}'
                echo '📊 状态: 已修改'
                echo '📏 大小: '$(ls -lh {} 2>/dev/null | awk '{print \$5}' || echo 'N/A')
                echo
                echo '🔄 差异预览:'
                git diff --color=always --stat {}
                echo
                git diff --color=always {} | head -50
            " \
            --header '🔄 选择文件查看差异 | CTRL-/: 切换预览')

        if [[ -n "$file" ]]; then
            echo "📄 查看文件差异: $file"
            git diff --color=always "$file" | $bat_cmd -l diff --style=numbers,changes
        fi
    }

    # =============================================================================
    # Git 别名覆盖配置 - 替代 Oh My Zsh 默认别名
    # =============================================================================

    # 主要功能别名（覆盖 Oh My Zsh 默认别名）
    # 注意：需要先取消现有别名，然后重新定义为我们的函数
    unalias gco 2>/dev/null; alias gco='_git_checkout_interactive'
    unalias glog 2>/dev/null; alias glog='_git_log_interactive'
    unalias gst 2>/dev/null; alias gst='_git_status_interactive'

    # 扩展功能别名
    alias gbr='_git_checkout_interactive'    # 分支切换（别名）
    alias glg='_git_log_interactive'         # 提交历史（别名）
    alias gstat='_git_status_interactive'    # 文件状态（别名）
    alias gsh='gstash'      # stash管理
    alias grm='gremote'     # 远程分支
    alias gfhist='gfh'      # 文件历史
    alias gbl='gblame'      # blame浏览（覆盖 Oh My Zsh 的 git blame -w）
    alias gdf='gdiff'       # 差异查看

    # 为 Oh My Zsh 原始功能提供替代别名
    alias gco-orig='git checkout'                           # 原始 checkout 命令
    alias glog-orig='git log --oneline --decorate --graph'  # 原始 log 命令
    alias gst-orig='git status'                             # 原始 status 命令
    alias gbl-orig='git blame -w'                           # 原始 blame 命令

    # Git 别名状态检查函数
    git-alias-status() {
        echo "📊 Git 别名覆盖状态:"
        echo
        echo "🔄 已覆盖的 Oh My Zsh 别名:"
        echo "  gco  -> 交互式分支切换 (原: git checkout)"
        echo "  glog -> 交互式提交历史 (原: git log --oneline --decorate --graph)"
        echo "  gst  -> 交互式文件状态 (原: git status)"
        echo "  gbl  -> 交互式 blame 浏览 (原: git blame -w)"
        echo
        echo "🔙 原始功能别名:"
        echo "  gco-orig  -> git checkout"
        echo "  glog-orig -> git log --oneline --decorate --graph"
        echo "  gst-orig  -> git status"
        echo "  gbl-orig  -> git blame -w"
        echo
        echo "🚀 增强功能别名:"
        echo "  gsh      -> stash 管理"
        echo "  grm      -> 远程分支管理"
        echo "  gfh      -> 文件历史浏览"
        echo "  gdiff    -> 交互式差异查看"
        echo
        echo "💡 运行 'alias | grep ^g' 查看所有 Git 别名"
    }

    # 显示加载信息
    echo "🔄 Git 集成已加载 - 已覆盖 Oh My Zsh 默认别名"
    echo "   主要覆盖: gco, glog, gst, gbl"
    echo "   原始功能: gco-orig, glog-orig, gst-orig, gbl-orig"
    echo "   运行 'git-alias-status' 查看详细状态"
fi
