#!/usr/bin/env python3

"""
扩展模块生成器
包含git集成、工具函数等扩展功能模块的生成函数
"""


class ExtendedModuleGenerators:
    """扩展Shell配置模块生成器"""

    def __init__(self):
        pass

    def generate_git_integration_module(self) -> str:
        """生成git集成模块"""
        return '''# git + fzf + bat集成功能

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
        git log --graph --color=always \\
            --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
        fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \\
            --bind "ctrl-m:execute:
                (grep -o '[a-f0-9]\\{7\\}' | head -1 |
                xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                {}
FZF-EOF"
    }

    # Git文件状态查看和操作
    gst() {
        git status --porcelain | \\
        fzf --multi --ansi --preview 'git diff --color=always {2}' \\
            --header 'TAB: 多选 | ENTER: git add | CTRL-R: git reset' \\
            --bind 'enter:execute-silent(git add {2})+reload(git status --porcelain)' \\
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
            git log --follow --patch --color=always -- "$file" | \\
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
            git blame --color-lines "$file" | \\
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
'''

    def generate_utility_functions_module(self) -> str:
        """生成通用工具函数模块"""
        return '''# 通用工具函数（search-all等）

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
        find "$search_path" -type f -name "*$query*" -not -path '*/\\.git/*' | head -10
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
        find "$search_path" -type d -name "*$query*" -not -path '*/\\.git/*' | head -5
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
        fdfind --type f --hidden --follow --exclude .git . "$path" -x ls -lah {} | \\
        sort -k5 -hr | head -10
    elif command -v fd >/dev/null 2>&1; then
        fd --type f --hidden --follow --exclude .git . "$path" -x ls -lah {} | \\
        sort -k5 -hr | head -10
    else
        find "$path" -type f -not -path '*/\\.git/*' -exec ls -lah {} \\; | \\
        sort -k5 -hr | head -10
    fi
    echo

    echo "📈 按扩展名统计:"
    if command -v fdfind >/dev/null 2>&1; then
        fdfind --type f --hidden --follow --exclude .git . "$path" | \\
        sed 's/.*\\.//' | sort | uniq -c | sort -nr | head -10
    elif command -v fd >/dev/null 2>&1; then
        fd --type f --hidden --follow --exclude .git . "$path" | \\
        sed 's/.*\\.//' | sort | uniq -c | sort -nr | head -10
    else
        find "$path" -type f -not -path '*/\\.git/*' | \\
        sed 's/.*\\.//' | sort | uniq -c | sort -nr | head -10
    fi
}

# 重复文件查找
find-duplicates() {
    local path="${1:-.}"
    echo "🔍 查找重复文件: $path"
    echo

    if command -v fdfind >/dev/null 2>&1; then
        fdfind --type f --hidden --follow --exclude .git . "$path" -x md5sum {} | \\
        sort | uniq -w32 -dD
    elif command -v fd >/dev/null 2>&1; then
        fd --type f --hidden --follow --exclude .git . "$path" -x md5sum {} | \\
        sort | uniq -w32 -dD
    else
        find "$path" -type f -not -path '*/\\.git/*' -exec md5sum {} \\; | \\
        sort | uniq -w32 -dD
    fi
}

# 空文件和空目录清理
clean-empty() {
    local path="${1:-.}"
    echo "🧹 清理空文件和空目录: $path"
    echo

    echo "空文件:"
    find "$path" -type f -empty -not -path '*/\\.git/*'
    echo

    echo "空目录:"
    find "$path" -type d -empty -not -path '*/\\.git/*'
    echo

    read -q "REPLY?确认删除这些空文件和目录? (y/N): "
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        find "$path" -type f -empty -not -path '*/\\.git/*' -delete
        find "$path" -type d -empty -not -path '*/\\.git/*' -delete
        echo "清理完成"
    fi
}

# 别名
alias sa='search-all'           # 综合搜索
alias qv='quick-view'           # 快速查看
alias fs='file-sizes'           # 文件大小分析
alias fd-dup='find-duplicates'  # 查找重复文件
alias clean='clean-empty'       # 清理空文件
'''

    def generate_aliases_summary_module(self) -> str:
        """生成别名汇总和show-tools功能模块"""
        return '''# 最终别名汇总和show-tools功能

# show-tools 函数 - 显示所有可用的工具和别名
show-tools() {
    echo "🚀 Shell Tools 功能概览"
    echo "=========================="
    echo

    # 核心工具状态
    echo "🔧 核心工具状态:"
    local tools=("bat" "fd" "fzf" "rg" "git")
    for tool in "${tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            printf "  ✅ %-8s %s\\n" "$tool" "$(command -v "$tool")"
        else
            printf "  ❌ %-8s %s\\n" "$tool" "未安装"
        fi
    done
    echo

    # 文件操作
    echo "📁 文件操作:"
    echo "  fe/fed     - 用fzf搜索并编辑文件"
    echo "  fp/ff      - 用fzf搜索并预览文件"
    echo "  fcd/fdir   - 用fzf搜索并跳转目录"
    echo "  fif        - 搜索文件内容并编辑"
    echo "  fdbat      - 用fd搜索文件并用bat查看"
    echo "  fdpreview  - 用fd搜索文件并预览"
    echo

    # 搜索功能
    echo "🔍 搜索功能:"
    echo "  rgf/rgfzf  - ripgrep + fzf交互搜索"
    echo "  rge/rged   - 搜索并编辑文件"
    echo "  rgc/rgctx  - 搜索并显示上下文"
    echo "  search-all/sa - 综合搜索（文件名+内容）"
    echo "  fms        - fzf多模式搜索"
    echo

    # Git集成
    if command -v git >/dev/null 2>&1; then
        echo "🌿 Git集成:"
        echo "  gco/gbr    - 分支选择和切换"
        echo "  glog/glg   - 提交历史浏览"
        echo "  gst/gstat  - 文件状态查看"
        echo "  gstash/gsh - stash管理"
        echo "  gdiff/gdf  - 差异查看"
        echo
    fi

    # 系统工具
    echo "⚙️ 系统工具:"
    echo "  fh/fhist   - 历史命令搜索"
    echo "  fkill      - 进程查看和终止"
    echo "  batman     - man页面搜索"
    echo "  fman       - fzf + man页面"
    echo "  af         - APT包搜索和安装"
    echo

    # 工具函数
    echo "🛠️ 工具函数:"
    echo "  quick-view/qv    - 快速文件查看"
    echo "  file-sizes/fs    - 文件大小分析"
    echo "  find-duplicates  - 查找重复文件"
    echo "  clean-empty      - 清理空文件和目录"
    echo

    # 调试和状态
    echo "🔧 调试和状态:"
    echo "  shell-tools-debug   - 显示详细调试信息"
    echo "  shell-tools-status  - 显示模块状态"
    echo "  shell-tools-reload  - 重新加载配置"
    echo

    # 使用提示
    echo "💡 使用提示:"
    echo "  - 大多数fzf功能支持多选（TAB键）"
    echo "  - 使用CTRL-C退出fzf界面"
    echo "  - 在fzf中使用CTRL-/切换预览"
    echo "  - 运行 'shell-tools-debug' 查看详细状态"
    echo

    echo "📚 更多信息: https://github.com/junegunn/fzf"
}

# 快速帮助别名
alias tools='show-tools'
alias help-tools='show-tools'
alias st='show-tools'

# 最终状态显示
echo "✨ Shell Tools 模块化配置加载完成"
echo "💡 运行 'show-tools' 或 'tools' 查看所有功能"
'''
