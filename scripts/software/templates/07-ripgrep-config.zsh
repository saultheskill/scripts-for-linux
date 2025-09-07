# ripgrep配置和基础集成

if command -v rg >/dev/null 2>&1; then
    # ripgrep 环境变量配置
    export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"

    # 创建ripgrep配置文件（如果不存在）
    if [[ ! -f "$RIPGREP_CONFIG_PATH" ]]; then
        cat > "$RIPGREP_CONFIG_PATH" << 'EOF'
# ripgrep配置文件
--max-columns=150
--max-columns-preview
--smart-case
--follow
--hidden
--glob=!.git/*
--glob=!node_modules/*
--glob=!.cache/*
--glob=!*.lock
--colors=line:none
--colors=line:style:bold
--colors=path:fg:green
--colors=path:style:bold
--colors=match:fg:black
--colors=match:bg:yellow
--colors=match:style:nobold
EOF
    fi

    # 基础ripgrep别名
    alias rgi='rg --ignore-case'                    # 忽略大小写搜索
    alias rgf='rg --files'                          # 列出将被搜索的文件
    alias rgl='rg --files-with-matches'             # 只显示匹配的文件名
    alias rgL='rg --files-without-match'            # 只显示不匹配的文件名
    alias rgv='rg --invert-match'                   # 反向匹配
    alias rgw='rg --word-regexp'                    # 全词匹配
    alias rgA='rg --after-context'                  # 显示匹配后的行
    alias rgB='rg --before-context'                 # 显示匹配前的行
    alias rgC='rg --context'                        # 显示匹配前后的行

    # 按文件类型搜索
    rg-py() { rg --type py "$@"; }                  # Python文件
    rg-js() { rg --type js "$@"; }                  # JavaScript文件
    rg-css() { rg --type css "$@"; }                # CSS文件
    rg-html() { rg --type html "$@"; }              # HTML文件
    rg-md() { rg --type md "$@"; }                  # Markdown文件
    rg-json() { rg --type json "$@"; }              # JSON文件
    rg-yaml() { rg --type yaml "$@"; }              # YAML文件
    rg-sh() { rg --type sh "$@"; }                  # Shell脚本

    # 搜索统计
    rg-stats() {
        if [[ $# -eq 0 ]]; then
            echo "用法: rg-stats <搜索词>"
            return 1
        fi
        echo "搜索统计: $1"
        echo "匹配文件数: $(rg -l "$1" | wc -l)"
        echo "匹配行数: $(rg -c "$1" | awk -F: '{sum += $2} END {print sum}')"
        echo "总匹配数: $(rg "$1" | wc -l)"
    }
fi
