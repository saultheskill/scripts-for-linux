# 通用工具函数（search-all等）

# 综合搜索函数 - search-all
search-all() {
    if [[ $# -eq 0 ]]; then
        echo "用法: search-all <搜索词> [路径]"
        echo "功能: 在文件名和文件内容中搜索"
        echo "示例: search-all python /home/user/projects"
        return 1
    fi

    local query="$1"
    local search_path="${2:-.}"
    
    echo "🔍 综合搜索: $query"
    echo "📁 搜索路径: $search_path"
    echo "=" | tr '=' '=' | head -c 50; echo

    # 1. 文件名搜索
    echo "📄 文件名匹配:"
    if command -v fdfind >/dev/null 2>&1; then
        fdfind --type f --hidden --follow --exclude .git "$query" "$search_path" | head -10
    elif command -v fd >/dev/null 2>&1; then
        fd --type f --hidden --follow --exclude .git "$query" "$search_path" | head -10
    else
        find "$search_path" -type f -name "*$query*" -not -path '*/\.git/*' | head -10
    fi
    echo

    # 2. 文件内容搜索
    echo "📝 文件内容匹配:"
    if command -v rg >/dev/null 2>&1; then
        rg --color=always --line-number --max-count=3 "$query" "$search_path" | head -15
    else
        grep -r --color=always -n --max-count=3 "$query" "$search_path" | head -15
    fi
    echo

    # 3. 目录名搜索
    echo "📂 目录名匹配:"
    if command -v fdfind >/dev/null 2>&1; then
        fdfind --type d --hidden --follow --exclude .git "$query" "$search_path" | head -5
    elif command -v fd >/dev/null 2>&1; then
        fd --type d --hidden --follow --exclude .git "$query" "$search_path" | head -5
    else
        find "$search_path" -type d -name "*$query*" -not -path '*/\.git/*' | head -5
    fi
}

# 快速文件查看
quick-view() {
    if [[ $# -eq 0 ]]; then
        echo "用法: quick-view <文件模式>"
        echo "示例: quick-view '*.py'"
        return 1
    fi

    local pattern="$1"
    
    # 确定使用的bat命令
    local bat_cmd
    if command -v batcat >/dev/null 2>&1; then
        bat_cmd='batcat'
    elif command -v bat >/dev/null 2>&1; then
        bat_cmd='bat'
    else
        bat_cmd='cat'
    fi
    
    if command -v fdfind >/dev/null 2>&1; then
        fdfind --type f "$pattern" | while read -r file; do
            echo "=== $file ==="
            $bat_cmd --line-range=:20 "$file"
            echo
        done
    elif command -v fd >/dev/null 2>&1; then
        fd --type f "$pattern" | while read -r file; do
            echo "=== $file ==="
            $bat_cmd --line-range=:20 "$file"
            echo
        done
    else
        find . -name "$pattern" -type f | while read -r file; do
            echo "=== $file ==="
            $bat_cmd --line-range=:20 "$file"
            echo
        done
    fi
}

# 文件大小分析
file-sizes() {
    local path="${1:-.}"
    echo "📊 文件大小分析: $path"
    echo
    
    echo "🔝 最大的10个文件:"
    if command -v fdfind >/dev/null 2>&1; then
        fdfind --type f --hidden --follow --exclude .git . "$path" -x ls -lah {} | \
        sort -k5 -hr | head -10
    elif command -v fd >/dev/null 2>&1; then
        fd --type f --hidden --follow --exclude .git . "$path" -x ls -lah {} | \
        sort -k5 -hr | head -10
    else
        find "$path" -type f -not -path '*/\.git/*' -exec ls -lah {} \; | \
        sort -k5 -hr | head -10
    fi
    echo
    
    echo "📈 按扩展名统计:"
    if command -v fdfind >/dev/null 2>&1; then
        fdfind --type f --hidden --follow --exclude .git . "$path" | \
        sed 's/.*\.//' | sort | uniq -c | sort -nr | head -10
    elif command -v fd >/dev/null 2>&1; then
        fd --type f --hidden --follow --exclude .git . "$path" | \
        sed 's/.*\.//' | sort | uniq -c | sort -nr | head -10
    else
        find "$path" -type f -not -path '*/\.git/*' | \
        sed 's/.*\.//' | sort | uniq -c | sort -nr | head -10
    fi
}

# 重复文件查找
find-duplicates() {
    local path="${1:-.}"
    echo "🔍 查找重复文件: $path"
    echo
    
    if command -v fdfind >/dev/null 2>&1; then
        fdfind --type f --hidden --follow --exclude .git . "$path" -x md5sum {} | \
        sort | uniq -w32 -dD
    elif command -v fd >/dev/null 2>&1; then
        fd --type f --hidden --follow --exclude .git . "$path" -x md5sum {} | \
        sort | uniq -w32 -dD
    else
        find "$path" -type f -not -path '*/\.git/*' -exec md5sum {} \; | \
        sort | uniq -w32 -dD
    fi
}

# 空文件和空目录清理
clean-empty() {
    local path="${1:-.}"
    echo "🧹 清理空文件和空目录: $path"
    echo
    
    echo "空文件:"
    find "$path" -type f -empty -not -path '*/\.git/*'
    echo
    
    echo "空目录:"
    find "$path" -type d -empty -not -path '*/\.git/*'
    echo
    
    read -q "REPLY?确认删除这些空文件和目录? (y/N): "
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        find "$path" -type f -empty -not -path '*/\.git/*' -delete
        find "$path" -type d -empty -not -path '*/\.git/*' -delete
        echo "清理完成"
    fi
}

# 别名
alias sa='search-all'           # 综合搜索
alias qv='quick-view'           # 快速查看
alias fs='file-sizes'           # 文件大小分析
alias fd-dup='find-duplicates'  # 查找重复文件
alias clean='clean-empty'       # 清理空文件
