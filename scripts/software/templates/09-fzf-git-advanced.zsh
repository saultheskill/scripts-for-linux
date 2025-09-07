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
    local fg="#CBE0F0"
    local bg="#011628"
    local bg_highlight="#143652"
    local purple="#B388FF"
    local blue="#06BCE4"
    local cyan="#2CF9ED"
    local green="#A4E400"
    local orange="#FF8A65"

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

    # Git 文件选择器
    _fzf_git_files() {
        git ls-files --cached --others --exclude-standard | \
        _fzf_git_fzf --preview "
            if [[ -f {} ]]; then
                $FZF_GIT_CAT {}
            else
                echo '文件不存在或为目录'
            fi
        " --header '📁 Git Files | TAB: 多选 | CTRL-/: 切换预览' "$@"
    }

    # Git 分支选择器
    _fzf_git_branches() {
        git branch -a --color=always | grep -v '/HEAD\s' | \
        _fzf_git_fzf --ansi --preview "
            branch=\$(echo {} | sed 's/^[* ] //' | sed 's/^remotes\///')
            git log --oneline --graph --color=always --date=short --pretty='format:%C(auto)%cd %h%d %s' \$branch | head -20
        " --header '🌿 Git Branches | TAB: 多选 | CTRL-/: 切换预览' "$@"
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

    # Git 提交哈希选择器
    _fzf_git_hashes() {
        git log --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" --graph --color=always | \
        _fzf_git_fzf --ansi --preview "
            hash=\$(echo {} | grep -o '[a-f0-9]\{7,\}' | head -1)
            git show --color=always \$hash
        " --header '📝 Git Commits | TAB: 多选 | CTRL-/: 切换预览' "$@"
    }

    # Git stash 选择器
    _fzf_git_stashes() {
        git stash list | \
        _fzf_git_fzf --preview "
            stash=\$(echo {} | cut -d: -f1)
            git stash show --color=always -p \$stash
        " --header '📦 Git Stashes | TAB: 多选 | CTRL-/: 切换预览' "$@"
    }

    # Git reflog 选择器
    _fzf_git_reflogs() {
        git reflog --color=always --format="%C(auto)%h %<|(20)%gd %C(blue)%cr%C(reset) %gs (%s)" | \
        _fzf_git_fzf --ansi --preview "
            hash=\$(echo {} | grep -o '^[a-f0-9]\+')
            git show --color=always \$hash
        " --header '📜 Git Reflog | TAB: 多选 | CTRL-/: 切换预览' "$@"
    }

    # Git worktree 选择器
    _fzf_git_worktrees() {
        git worktree list | \
        _fzf_git_fzf --preview "
            path=\$(echo {} | awk '{print \$1}')
            echo '工作树路径: '\$path
            echo '分支信息:'
            cd \$path && git status --short 2>/dev/null || echo '无法获取状态'
        " --header '🌳 Git Worktrees | TAB: 多选 | CTRL-/: 切换预览' "$@"
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
                echo "fzf-git 键盘绑定帮助:"
                echo "  CTRL-G CTRL-F  📁 Files      - Git 文件选择"
                echo "  CTRL-G CTRL-B  🌿 Branches   - Git 分支选择"
                echo "  CTRL-G CTRL-T  🏷️  Tags       - Git 标签选择"
                echo "  CTRL-G CTRL-R  🌐 Remotes    - Git 远程仓库"
                echo "  CTRL-G CTRL-H  📝 Hashes     - Git 提交哈希"
                echo "  CTRL-G CTRL-S  📦 Stashes    - Git 储藏"
                echo "  CTRL-G CTRL-L  📜 Reflogs    - Git 引用日志"
                echo "  CTRL-G CTRL-W  🌳 Worktrees  - Git 工作树"
                echo "  CTRL-G CTRL-E  🔗 Each-ref   - Git 引用"
                echo "  CTRL-G ?       ❓ Help       - 显示此帮助"
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
            read -k key
            __fzf_git_init "$key"
        }

        zle -N __fzf_git_widget
        bindkey '^G' __fzf_git_widget
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

    # 提示信息
    echo "🚀 fzf-git 高级功能已加载"
    echo "   使用 CTRL-G ? 查看键盘绑定帮助"
    echo "   或使用便捷函数: gco-f, gsw, gsh-f, gst-f"
fi
