# fzf基础功能（文件搜索、编辑等）

if command -v fzf >/dev/null 2>&1; then
    # 确定使用的bat命令
    if command -v batcat >/dev/null 2>&1; then
        local bat_cmd='batcat'
    elif command -v bat >/dev/null 2>&1; then
        local bat_cmd='bat'
    else
        local bat_cmd='cat'
    fi

    # 基础文件搜索和编辑功能
    # 使用fzf搜索文件并用默认编辑器打开
    fe() {
        local files
        IFS=$'\n' files=($(fzf-tmux --query="$1" --multi --select-1 --exit-0))
        [[ -n "$files" ]] && ${EDITOR:-vim} "${files[@]}"
    }

    # 使用fzf搜索文件并用bat预览
    fp() {
        fzf --preview "$bat_cmd --color=always --style=numbers --line-range=:500 {}" "$@"
    }

    # 搜索文件内容并编辑
    fif() {
        if [ ! "$#" -gt 0 ]; then
            echo "用法: fif <搜索词>"
            return 1
        fi
        
        # 使用rg搜索，如果没有则使用grep
        if command -v rg >/dev/null 2>&1; then
            local file
            file="$(rg --files-with-matches --no-messages "$1" | fzf --preview "rg --ignore-case --pretty --context 10 '$1' {}")" &&
            ${EDITOR:-vim} "$file"
        else
            local file
            file="$(grep -r -l "$1" . | fzf --preview "grep --color=always -n '$1' {}")" &&
            ${EDITOR:-vim} "$file"
        fi
    }

    # 快速目录跳转
    fcd() {
        local dir
        # 使用fd查找目录，如果没有则使用find
        if command -v fd >/dev/null 2>&1; then
            dir=$(fd --type d --hidden --follow --exclude .git | fzf +m) &&
            cd "$dir"
        elif command -v fdfind >/dev/null 2>&1; then
            dir=$(fdfind --type d --hidden --follow --exclude .git | fzf +m) &&
            cd "$dir"
        else
            dir=$(find . -type d -not -path '*/\.git/*' | fzf +m) &&
            cd "$dir"
        fi
    }

    # 历史命令搜索增强
    fh() {
        print -z $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed -E 's/ *[0-9]*\*? *//' | sed -E 's/\\n/\n/')
    }

    # 进程查看和终止
    fkill() {
        local pid
        if [ "$UID" != "0" ]; then
            pid=$(ps -f -u $UID | sed 1d | fzf -m | awk '{print $2}')
        else
            pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
        fi

        if [ "x$pid" != "x" ]; then
            echo $pid | xargs kill -${1:-9}
        fi
    }

    # 别名
    alias ff='fp'           # 文件预览
    alias fed='fe'          # 文件编辑
    alias fdir='fcd'        # 目录跳转
    alias fhist='fh'        # 历史搜索
fi
