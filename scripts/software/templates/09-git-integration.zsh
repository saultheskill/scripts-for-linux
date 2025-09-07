# git + fzf + bat集成功能

if command -v git >/dev/null 2>&1 && command -v fzf >/dev/null 2>&1; then
    # 确定使用的bat命令
    if command -v batcat >/dev/null 2>&1; then
        local bat_cmd='batcat'
    elif command -v bat >/dev/null 2>&1; then
        local bat_cmd='bat'
    else
        local bat_cmd='cat'
    fi

    # Git分支选择和切换
    gco() {
        local branches branch
        branches=$(git --no-pager branch -vv) &&
        branch=$(echo "$branches" | fzf +m) &&
        git checkout $(echo "$branch" | awk '{print $1}' | sed "s/.* //")
    }

    # Git提交历史浏览
    glog() {
        git log --graph --color=always \
            --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
        fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
            --bind "ctrl-m:execute:
                (grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                {}
FZF-EOF"
    }

    # Git文件状态查看和操作
    gst() {
        git status --porcelain | \
        fzf --multi --ansi --preview 'git diff --color=always {2}' \
            --header 'TAB: 多选 | ENTER: git add | CTRL-R: git reset' \
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

    # Git文件历史
    gfh() {
        local file="$1"
        if [[ -z "$file" ]]; then
            file=$(git ls-files | fzf --preview "$bat_cmd --color=always {}")
        fi
        
        if [[ -n "$file" ]]; then
            git log --follow --patch --color=always -- "$file" | \
            fzf --ansi --no-sort --reverse --tiebreak=index
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

    # Git差异查看
    gdiff() {
        local file
        file=$(git diff --name-only | fzf --preview 'git diff --color=always {}')
        if [[ -n "$file" ]]; then
            git diff "$file" | $bat_cmd -l diff
        fi
    }

    # 别名
    alias gbr='gco'         # 分支切换
    alias glg='glog'        # 提交历史
    alias gstat='gst'       # 文件状态
    alias gsh='gstash'      # stash管理
    alias grm='gremote'     # 远程分支
    alias gfhist='gfh'      # 文件历史
    alias gbl='gblame'      # blame浏览
    alias gdf='gdiff'       # 差异查看
fi
