# eza (现代化 ls 替代品) 配置
# eza 是 exa 的现代继任者，提供更好的性能和更多功能

if command -v eza >/dev/null 2>&1; then
    # 基础环境变量配置
    export EZA_COLORS="reset:di=1;34:ln=1;36:so=1;35:pi=1;33:ex=1;32:bd=1;33:cd=1;33:su=1;31:sg=1;31:tw=1;34:ow=1;34"
    export EZA_ICON_SPACING=2
    export EZA_GRID_ROWS=3

    # 创建配置目录
    if [[ ! -d "${XDG_CONFIG_HOME:-$HOME/.config}/eza" ]]; then
        mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/eza"
    fi

    # 基础别名 - 替代传统 ls 命令
    alias ls='eza --color=auto --icons=auto --group-directories-first'
    alias ll='eza --long --header --icons=auto --group-directories-first --git'
    alias la='eza --long --all --header --icons=auto --group-directories-first --git'
    alias l='eza --oneline --icons=auto'

    # 树形视图别名
    alias tree='eza --tree --icons=auto --group-directories-first'
    alias tree2='eza --tree --level=2 --icons=auto --group-directories-first'
    alias tree3='eza --tree --level=3 --icons=auto --group-directories-first'
    alias treel='eza --tree --long --icons=auto --group-directories-first --git'

    # 特殊用途别名
    alias lsa='eza --long --all --header --icons=auto --sort=size --reverse'  # 按大小排序
    alias lst='eza --long --header --icons=auto --sort=modified --reverse'    # 按时间排序
    alias lsg='eza --long --header --icons=auto --git --git-repos'            # Git 状态
    alias lsb='eza --long --header --icons=auto --binary --total-size'        # 二进制大小

    # 高级功能别名
    alias ezat='eza --tree --long --icons=auto --git --header --level=3'      # 树形详细视图
    alias ezag='eza --long --icons=auto --git --git-repos --header --group-directories-first'  # Git 增强视图
    alias ezas='eza --long --icons=auto --sort=size --reverse --header --total-size'  # 大小排序视图
    alias ezad='eza --only-dirs --icons=auto --long --header'                 # 仅目录
    alias ezaf='eza --only-files --icons=auto --long --header'                # 仅文件

    # 实用函数

    # 智能列表函数 - 根据参数自动选择最佳显示方式
    ezasmart() {
        local target="${1:-.}"
        local file_count

        if [[ -d "$target" ]]; then
            file_count=$(eza --oneline "$target" 2>/dev/null | wc -l)

            if [[ $file_count -gt 50 ]]; then
                echo "📁 目录包含 $file_count 个项目，使用简洁视图："
                eza --oneline --icons=auto --group-directories-first "$target"
            elif [[ $file_count -gt 20 ]]; then
                echo "📁 目录包含 $file_count 个项目，使用网格视图："
                eza --grid --icons=auto --group-directories-first "$target"
            else
                echo "📁 目录包含 $file_count 个项目，使用详细视图："
                eza --long --header --icons=auto --group-directories-first --git "$target"
            fi
        else
            eza --long --header --icons=auto --git "$target"
        fi
    }

    # 递归大小分析函数
    ezasize() {
        local target="${1:-.}"
        echo "📊 分析目录大小: $target"
        eza --long --total-size --sort=size --reverse --icons=auto --header "$target"

        if [[ -d "$target" ]]; then
            echo
            echo "🔍 子目录大小排序:"
            eza --only-dirs --long --total-size --sort=size --reverse --icons=auto "$target"
        fi
    }

    # Git 状态增强函数
    ezagit() {
        local target="${1:-.}"

        if git rev-parse --git-dir >/dev/null 2>&1; then
            echo "📝 Git 仓库状态视图:"
            eza --long --header --icons=auto --git --git-repos --group-directories-first "$target"

            echo
            echo "🔄 Git 状态统计:"
            local modified=$(git status --porcelain | grep "^ M" | wc -l)
            local added=$(git status --porcelain | grep "^A" | wc -l)
            local deleted=$(git status --porcelain | grep "^D" | wc -l)
            local untracked=$(git status --porcelain | grep "^??" | wc -l)

            echo "  修改: $modified | 新增: $added | 删除: $deleted | 未跟踪: $untracked"
        else
            echo "❌ 当前目录不是 Git 仓库"
            eza --long --header --icons=auto --group-directories-first "$target"
        fi
    }

    # 时间线视图函数
    ezatime() {
        local target="${1:-.}"
        local days="${2:-7}"

        echo "⏰ 最近 $days 天的文件时间线:"
        eza --long --header --icons=auto --sort=modified --reverse \
            --time-style=relative --group-directories-first "$target" | head -20
    }

    # 文件类型统计函数
    ezastats() {
        local target="${1:-.}"

        echo "📈 文件类型统计: $target"
        echo

        if [[ -d "$target" ]]; then
            echo "📁 目录统计:"
            local dirs=$(eza --only-dirs --oneline "$target" 2>/dev/null | wc -l)
            local files=$(eza --only-files --oneline "$target" 2>/dev/null | wc -l)
            local total=$((dirs + files))

            echo "  总计: $total | 目录: $dirs | 文件: $files"

            echo
            echo "📄 文件扩展名统计:"
            eza --only-files --oneline "$target" 2>/dev/null | \
                sed 's/.*\.//' | sort | uniq -c | sort -nr | head -10 | \
                while read count ext; do
                    echo "  .$ext: $count 个文件"
                done
        else
            echo "❌ 请指定一个目录"
        fi
    }

    # 快速搜索函数（结合 fzf 如果可用）
    ezafind() {
        local pattern="$1"
        local target="${2:-.}"

        if [[ -z "$pattern" ]]; then
            echo "用法: ezafind <搜索模式> [目录]"
            return 1
        fi

        echo "🔍 搜索包含 '$pattern' 的文件:"

        if command -v fzf >/dev/null 2>&1; then
            eza --recurse --oneline --icons=auto "$target" | \
                grep -i "$pattern" | \
                fzf --preview "eza --long --icons=auto --header {}" \
                    --header "搜索结果: $pattern"
        else
            eza --recurse --long --icons=auto --header "$target" | grep -i "$pattern"
        fi
    }

    # 别名汇总
    alias ezal='ezasmart'      # 智能列表
    alias ezas='ezasize'       # 大小分析
    alias ezag='ezagit'        # Git 状态
    alias ezat='ezatime'       # 时间线
    alias ezast='ezastats'     # 统计信息
    alias ezaf='ezafind'       # 搜索文件

    echo "🚀 eza 配置已加载"
    echo "   基础: ls, ll, la, tree"
    echo "   高级: ezal, ezas, ezag, ezat, ezast, ezaf"

elif command -v exa >/dev/null 2>&1; then
    # 如果只有 exa，提供基础配置
    alias ls='exa --color=auto --icons --group-directories-first'
    alias ll='exa --long --header --icons --group-directories-first --git'
    alias la='exa --long --all --header --icons --group-directories-first --git'
    alias tree='exa --tree --icons --group-directories-first'

    echo "📦 exa 配置已加载（建议升级到 eza）"
    echo "   💡 升级指南: https://github.com/eza-community/eza"
else
    echo "⚠️  未找到 eza 或 exa，使用基础 ls 配置"
fi
