# fzf-git 高级集成功能
# 基于 junegunn/fzf-git.sh 项目的键盘绑定和交互功能
# 提供 CTRL-G 系列快捷键用于 Git 对象的快速选择和操作

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

    # 环境变量配置
    export FZF_GIT_COLOR="${FZF_GIT_COLOR:-always}"
    export FZF_GIT_PREVIEW_COLOR="${FZF_GIT_PREVIEW_COLOR:-always}"
    export FZF_GIT_CAT="${FZF_GIT_CAT:-$bat_cmd --style=numbers,changes --color=always --line-range=:500}"
    export FZF_GIT_PAGER="${FZF_GIT_PAGER:-$(git config --get core.pager || echo 'less -R')}"

    # 自定义 fzf 配置函数 - 美化版
    _fzf_git_fzf() {
        fzf --height 80% --tmux 95%,80% \
            --layout reverse --multi --min-height 25+ \
            --border rounded --border-label-pos 2 \
            --color "fg:${fg},bg:${bg},hl:${purple},fg+:${fg},bg+:${bg_highlight},hl+:${purple}" \
            --color "info:${blue},prompt:${cyan},pointer:${cyan},marker:${green},spinner:${orange},header:${cyan}" \
            --color "border:${blue},label:${cyan},preview-border:${purple}" \
            --preview-window 'right,55%,border-left' \
            --bind 'ctrl-/:change-preview-window(down,60%,border-top|right,55%,border-left|hidden)' \
            --bind 'ctrl-o:execute-silent(echo {} | grep -o "[a-f0-9]\{7,\}" | head -1 | xargs -I % sh -c "git show --color=always % | head -30")' \
            --bind 'ctrl-y:execute-silent(echo {} | pbcopy)' \
            --bind 'ctrl-r:reload(eval "$FZF_DEFAULT_COMMAND")' \
            --bind 'alt-a:select-all' \
            --bind 'alt-d:deselect-all' \
            --prompt "🔍 " --pointer "▶" --marker "✓" \
            --header-first \
            "$@"
    }

    # Git 文件选择器 - 增强预览
    _fzf_git_files() {
        git ls-files --cached --others --exclude-standard | \
        _fzf_git_fzf --preview "
            if [[ -f {} ]]; then
                echo '📄 文件: {}'
                echo '📊 状态: '$(git status --porcelain {} 2>/dev/null | cut -c1-2 || echo '  ')
                echo '📏 大小: '$(ls -lh {} 2>/dev/null | awk '{print \$5}' || echo 'N/A')
                echo '🕒 修改: '$(stat -c '%y' {} 2>/dev/null | cut -d. -f1 || echo 'N/A')
                echo
                $FZF_GIT_CAT {}
            elif [[ -d {} ]]; then
                echo '📁 目录: {}'
                echo
                if command -v eza >/dev/null 2>&1; then
                    eza --tree --color=always --icons=auto --level=2 {} | head -20
                elif command -v exa >/dev/null 2>&1; then
                    exa --tree --color=always --level=2 {} | head -20
                else
                    ls -la {} | head -20
                fi
            else
                echo '❌ 文件不存在: {}'
            fi
        " --header '📁 Git Files | TAB: 多选 | CTRL-/: 切换预览 | CTRL-Y: 复制路径' "$@"
    }

    # Git 分支选择器 - 增强预览
    _fzf_git_branches() {
        git branch -a --color=always | grep -v '/HEAD\s' | \
        _fzf_git_fzf --ansi --preview "
            branch=\$(echo {} | sed 's/^[* ] //' | sed 's/^remotes\///')
            echo '🌿 分支: '\$branch
            echo '📊 统计:'
            echo '  提交数: '$(git rev-list --count \$branch 2>/dev/null || echo '0')
            echo '  最后提交: '$(git log -1 --format='%cr' \$branch 2>/dev/null || echo 'N/A')
            echo '  作者: '$(git log -1 --format='%an' \$branch 2>/dev/null || echo 'N/A')
            echo
            echo '📝 最近提交:'
            git log --oneline --graph --color=always --date=short \
                --pretty='format:%C(yellow)%h%C(reset) %C(blue)%ad%C(reset) %C(green)(%an)%C(reset) %s%C(auto)%d' \
                \$branch | head -15
        " --header '🌿 Git Branches | TAB: 多选 | CTRL-/: 切换预览 | CTRL-Y: 复制分支名' "$@"
    }

    # Git 标签选择器
    _fzf_git_tags() {
        git tag --sort=-version:refname | \
        _fzf_git_fzf --preview "
            git show --color=always {} | head -20
        " --header '🏷️  Git Tags | TAB: 多选 | CTRL-/: 切换预览' "$@"
    }

    # Git 远程仓库选择器
    _fzf_git_remotes() {
        git remote -v | awk '{print $1 \"\t\" $2}' | uniq | \
        _fzf_git_fzf --preview "
            remote=\$(echo {} | cut -f1)
            echo '远程仓库信息:'
            git remote show \$remote 2>/dev/null || echo '无法获取远程仓库信息'
        " --header '🌐 Git Remotes | TAB: 多选 | CTRL-/: 切换预览' "$@"
    }

    # Git 提交哈希选择器 - 增强预览
    _fzf_git_hashes() {
        git log --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s %C(blue)(%an)" --graph --color=always | \
        _fzf_git_fzf --ansi --preview "
            hash=\$(echo {} | grep -o '[a-f0-9]\{7,\}' | head -1)
            if [[ -n \$hash ]]; then
                echo '📝 提交: '\$hash
                echo '👤 作者: '$(git show -s --format='%an <%ae>' \$hash)
                echo '🕒 时间: '$(git show -s --format='%cd' --date=format:'%Y-%m-%d %H:%M:%S' \$hash)
                echo '📊 统计: '$(git show --stat \$hash | tail -1)
                echo
                echo '💬 提交信息:'
                git show -s --format='%B' \$hash | head -10
                echo
                echo '🔄 文件变更:'
                git show --color=always --stat \$hash
                echo
                echo '📄 详细差异:'
                git show --color=always \$hash | head -50
            else
                echo '❌ 无法解析提交哈希'
            fi
        " --header '📝 Git Commits | TAB: 多选 | CTRL-/: 切换预览 | CTRL-Y: 复制哈希' "$@"
    }

    # Git stash 选择器 - 增强预览
    _fzf_git_stashes() {
        git stash list | \
        _fzf_git_fzf --preview "
            stash=\$(echo {} | cut -d: -f1)
            echo '📦 Stash: '\$stash
            echo '📝 描述: '$(echo {} | cut -d: -f3-)
            echo '🕒 时间: '$(git stash list --format='%gd: %cr' | grep \$stash | cut -d: -f2-)
            echo '👤 作者: '$(git stash list --format='%gd: %an' | grep \$stash | cut -d: -f2-)
            echo
            echo '📊 统计:'
            git stash show --stat \$stash 2>/dev/null || echo '  无统计信息'
            echo
            echo '🔄 详细变更:'
            git stash show --color=always -p \$stash | head -40
        " --header '📦 Git Stashes | TAB: 多选 | CTRL-/: 切换预览 | CTRL-Y: 复制stash名' "$@"
    }

    # Git reflog 选择器
    _fzf_git_reflogs() {
        git reflog --color=always --format="%C(auto)%h %<|(20)%gd %C(blue)%cr%C(reset) %gs (%s)" | \
        _fzf_git_fzf --ansi --preview "
            hash=\$(echo {} | grep -o '^[a-f0-9]\+')
            git show --color=always \$hash
        " --header '📜 Git Reflog | TAB: 多选 | CTRL-/: 切换预览' "$@"
    }

    # Git worktree 选择器 - 增强预览
    _fzf_git_worktrees() {
        git worktree list | \
        _fzf_git_fzf --preview "
            path=\$(echo {} | awk '{print \$1}')
            branch=\$(echo {} | awk '{print \$3}' | sed 's/[][]//g')
            echo '🌳 工作树: '\$path
            echo '🌿 分支: '\$branch
            echo '📊 状态: '$(echo {} | awk '{print \$2}' | sed 's/[][]//g')
            echo
            if [[ -d \$path ]]; then
                echo '📁 目录内容:'
                if command -v eza >/dev/null 2>&1; then
                    eza --tree --color=always --icons=auto --level=2 \$path | head -15
                elif command -v exa >/dev/null 2>&1; then
                    exa --tree --color=always --level=2 \$path | head -15
                else
                    ls -la \$path | head -15
                fi
                echo
                echo '🔄 Git 状态:'
                cd \$path && git status --short 2>/dev/null | head -10 || echo '  无变更'
            else
                echo '❌ 路径不存在'
            fi
        " --header '🌳 Git Worktrees | TAB: 多选 | CTRL-/: 切换预览 | CTRL-Y: 复制路径' "$@"
    }

    # Git for-each-ref 选择器
    _fzf_git_each_ref() {
        git for-each-ref --format="%(refname:short) %(objecttype) %(subject)" refs/ | \
        _fzf_git_fzf --preview "
            ref=\$(echo {} | awk '{print \$1}')
            git show --color=always \$ref
        " --header '🔗 Git References | TAB: 多选 | CTRL-/: 切换预览' "$@"
    }

    # 键盘绑定函数
    __fzf_git_init() {
        # 检查是否在 git 仓库中
        if ! git rev-parse --git-dir >/dev/null 2>&1; then
            echo "不在 Git 仓库中"
            return 1
        fi

        local key="$1"
        local selected

        case "$key" in
            "?")
                echo "╭─────────────────────────────────────────────────────────────╮"
                echo "│                    🚀 fzf-git 键盘绑定帮助                    │"
                echo "├─────────────────────────────────────────────────────────────┤"
                echo "│  CTRL-G CTRL-F  📁 Files      - Git 文件选择与预览         │"
                echo "│  CTRL-G CTRL-B  🌿 Branches   - Git 分支选择与统计         │"
                echo "│  CTRL-G CTRL-T  🏷️  Tags       - Git 标签选择与详情         │"
                echo "│  CTRL-G CTRL-R  🌐 Remotes    - Git 远程仓库管理           │"
                echo "│  CTRL-G CTRL-H  📝 Hashes     - Git 提交哈希浏览           │"
                echo "│  CTRL-G CTRL-S  📦 Stashes    - Git 储藏管理               │"
                echo "│  CTRL-G CTRL-L  📜 Reflogs    - Git 引用日志查看           │"
                echo "│  CTRL-G CTRL-W  🌳 Worktrees  - Git 工作树管理             │"
                echo "│  CTRL-G CTRL-E  🔗 Each-ref   - Git 引用浏览               │"
                echo "│  CTRL-G ?       ❓ Help       - 显示此帮助                 │"
                echo "├─────────────────────────────────────────────────────────────┤"
                echo "│  快捷键: TAB(多选) CTRL-/(预览) CTRL-Y(复制) ALT-A(全选)    │"
                echo "│  导航键: ↑↓(选择) ENTER(确认) ESC(退出) CTRL-C(取消)        │"
                echo "╰─────────────────────────────────────────────────────────────╯"
                ;;
            "f"|"F")
                selected=$(_fzf_git_files --no-multi)
                ;;
            "b"|"B")
                selected=$(_fzf_git_branches --no-multi)
                ;;
            "t"|"T")
                selected=$(_fzf_git_tags --no-multi)
                ;;
            "r"|"R")
                selected=$(_fzf_git_remotes --no-multi)
                ;;
            "h"|"H")
                selected=$(_fzf_git_hashes --no-multi)
                ;;
            "s"|"S")
                selected=$(_fzf_git_stashes --no-multi)
                ;;
            "l"|"L")
                selected=$(_fzf_git_reflogs --no-multi)
                ;;
            "w"|"W")
                selected=$(_fzf_git_worktrees --no-multi)
                ;;
            "e"|"E")
                selected=$(_fzf_git_each_ref --no-multi)
                ;;
            *)
                echo "未知的键: $key"
                echo "使用 CTRL-G ? 查看帮助"
                return 1
                ;;
        esac

        if [[ -n "$selected" ]]; then
            # 清理选择结果并输出到命令行
            local cleaned=$(echo "$selected" | sed 's/^[* ] //' | sed 's/^remotes\///' | awk '{print $1}')
            LBUFFER="${LBUFFER}${cleaned}"
            zle reset-prompt
        fi
    }

    # 注册 zsh 键盘绑定
    if [[ -n "${ZSH_VERSION:-}" ]]; then
        # 创建 zle widget
        __fzf_git_widget() {
            local key
            echo -n "fzf-git: 按键选择 (? 查看帮助): "
            read -k key
            echo  # 换行
            __fzf_git_init "$key"
        }

        zle -N __fzf_git_widget
        bindkey '^G' __fzf_git_widget

        # 直接绑定常用组合键
        __fzf_git_files_widget() { _fzf_git_files --no-multi; }
        __fzf_git_branches_widget() { _fzf_git_branches --no-multi; }
        __fzf_git_hashes_widget() { _fzf_git_hashes --no-multi; }

        zle -N __fzf_git_files_widget
        zle -N __fzf_git_branches_widget
        zle -N __fzf_git_hashes_widget

        # 绑定快捷键
        bindkey '^G^F' __fzf_git_files_widget
        bindkey '^G^B' __fzf_git_branches_widget
        bindkey '^G^H' __fzf_git_hashes_widget
    fi

    # 便捷函数定义
    # Git 快速切换分支
    gco-fzf() {
        local branch
        branch=$(_fzf_git_branches --no-multi | sed 's/^[* ] //' | sed 's/^remotes\///')
        if [[ -n "$branch" ]]; then
            git checkout "$branch"
        fi
    }

    # Git 快速切换工作树
    gswt() {
        local worktree
        worktree=$(_fzf_git_worktrees --no-multi | awk '{print $1}')
        if [[ -n "$worktree" ]]; then
            cd "$worktree"
        fi
    }

    # Git 快速查看提交
    gshow() {
        local hash
        hash=$(_fzf_git_hashes --no-multi | grep -o '[a-f0-9]\{7,\}' | head -1)
        if [[ -n "$hash" ]]; then
            git show "$hash"
        fi
    }

    # Git 快速应用 stash
    gstash-apply() {
        local stash
        stash=$(_fzf_git_stashes --no-multi | cut -d: -f1)
        if [[ -n "$stash" ]]; then
            git stash apply "$stash"
        fi
    }

    # 别名定义
    alias gco-f='gco-fzf'           # fzf 分支切换
    alias gsw='gswt'                # 工作树切换
    alias gsh-f='gshow'             # fzf 提交查看
    alias gst-f='gstash-apply'      # fzf stash 应用

    # 美化的提示信息
    echo "╭─────────────────────────────────────────────────────────────╮"
    echo "│                🚀 fzf-git 高级功能已加载                    │"
    echo "├─────────────────────────────────────────────────────────────┤"
    echo "│  键盘绑定: CTRL-G ? (帮助)  CTRL-G CTRL-F (文件)           │"
    echo "│  便捷函数: gco-f (分支)  gsw (工作树)  gsh-f (提交)         │"
    echo "│  美化界面: 彩色主题 + 图标 + 实时预览 + 多选支持            │"
    echo "╰─────────────────────────────────────────────────────────────╯"
fi
