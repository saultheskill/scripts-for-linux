# ripgrep + fzf高级集成功能

if command -v rg >/dev/null 2>&1 && command -v fzf >/dev/null 2>&1; then
    # 确定使用的bat命令
    if command -v batcat >/dev/null 2>&1; then
        local bat_cmd='batcat'
    elif command -v bat >/dev/null 2>&1; then
        local bat_cmd='bat'
    else
        local bat_cmd='cat'
    fi

    # 交互式ripgrep搜索 - 主要功能
    rgf() {
        local initial_query="${*:-}"
        local rg_prefix="rg --column --line-number --no-heading --color=always --smart-case"
        local fzf_default_opts="
            --ansi
            --disabled
            --query=\"$initial_query\"
            --bind=\"change:reload:sleep 0.1; $rg_prefix {q} || true\"
            --bind=\"ctrl-f:unbind(change,ctrl-f)+change-prompt(2. fzf> )+enable-search+clear-query+rebind(ctrl-r)\"
            --bind=\"ctrl-r:unbind(ctrl-r)+change-prompt(1. ripgrep> )+disable-search+reload($rg_prefix {q} || true)+rebind(change,ctrl-f)\"
            --color=\"hl:-1:underline,hl+:-1:underline:reverse\"
            --prompt=\"1. ripgrep> \"
            --delimiter=:
            --header=\"CTRL-F: 切换到fzf模式 | CTRL-R: 切换到ripgrep模式\"
            --preview=\"$bat_cmd --color=always {1} --highlight-line {2}\"
            --preview-window=\"up,60%,border-bottom,+{2}+3/3,~3\"
        "
        
        FZF_DEFAULT_OPTS="$fzf_default_opts" fzf
    }

    # 在当前目录搜索并编辑
    rge() {
        local file line
        read -r file line <<< "$(rgf "$@" | head -1 | awk -F: '{print $1, $2}')"
        if [[ -n "$file" ]]; then
            ${EDITOR:-vim} +"$line" "$file"
        fi
    }

    # 搜索并显示上下文
    rgc() {
        if [[ $# -eq 0 ]]; then
            echo "用法: rgc <搜索词> [上下文行数，默认3]"
            return 1
        fi
        local context=${2:-3}
        rg --context "$context" --color=always "$1" | fzf --ansi --preview="echo {}" --preview-window=up:50%
    }

    # 多文件类型搜索
    rgm() {
        if [[ $# -eq 0 ]]; then
            echo "用法: rgm <搜索词>"
            echo "支持的文件类型: py, js, css, html, md, json, yaml, sh"
            return 1
        fi
        
        local query="$1"
        local types=("py" "js" "css" "html" "md" "json" "yaml" "sh")
        
        for type in "${types[@]}"; do
            echo "=== $type 文件 ==="
            rg --type "$type" --color=always "$query" | head -5
            echo
        done | fzf --ansi --preview="echo {}" --header="多文件类型搜索结果: $query"
    }

    # 搜索替换预览
    rgs() {
        if [[ $# -lt 2 ]]; then
            echo "用法: rgs <搜索词> <替换词> [文件模式]"
            return 1
        fi
        
        local search="$1"
        local replace="$2"
        local pattern="${3:-.}"
        
        echo "搜索替换预览:"
        echo "搜索: $search"
        echo "替换: $replace"
        echo "范围: $pattern"
        echo
        
        rg --color=always "$search" "$pattern" | \
        fzf --ansi \
            --preview="echo '原文:'; echo {}; echo; echo '替换后:'; echo {} | sed 's/$search/$replace/g'" \
            --header="预览搜索替换结果 | ENTER: 执行替换"
        
        read -q "REPLY?确认执行替换操作? (y/N): "
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rg --files-with-matches "$search" "$pattern" | xargs sed -i "s/$search/$replace/g"
            echo "替换完成"
        fi
    }

    # 别名
    alias rgfzf='rgf'       # ripgrep + fzf交互搜索
    alias rged='rge'        # 搜索并编辑
    alias rgctx='rgc'       # 搜索显示上下文
    alias rgmulti='rgm'     # 多文件类型搜索
    alias rgreplace='rgs'   # 搜索替换预览
fi
