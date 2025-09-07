# APT包管理集成功能

if command -v apt-cache >/dev/null 2>&1 && command -v fzf >/dev/null 2>&1 && command -v xargs >/dev/null 2>&1; then
    # 交互式APT软件包搜索和安装 - 主要功能
    alias af='apt-cache search "" | sort | cut --delimiter " " --fields 1 | fzf --multi --cycle --reverse --preview-window=right:70%:wrap --preview "apt-cache show {1}" | xargs -r sudo apt install -y'

    # APT软件包搜索（仅搜索，不安装）
    apt-search() {
        if [[ $# -eq 0 ]]; then
            echo "用法: apt-search [搜索词]"
            echo "功能: 交互式搜索APT软件包（不安装）"
            echo "示例: apt-search python"
            return 1
        fi

        # 修复：正确传递搜索参数给apt-cache search
        apt-cache search "$*" | sort |
        fzf --multi --cycle --reverse \
            --query="$*" \
            --preview-window=right:70%:wrap \
            --preview "apt-cache show {1}" \
            --header "搜索: $* | TAB: 多选 | ENTER: 查看详情 | ESC: 退出" |
        cut --delimiter " " --fields 1
    }

    # APT已安装软件包管理
    apt-installed() {
        dpkg --get-selections | grep -v deinstall | cut -f1 |
        fzf --multi --cycle --reverse \
            --preview-window=right:70%:wrap \
            --preview "apt-cache show {1}" \
            --header "已安装的软件包 | TAB: 多选 | ENTER: 查看详情"
    }

    # APT软件包信息查看
    apt-info() {
        if [[ $# -eq 0 ]]; then
            echo "用法: apt-info <软件包名>"
            echo "功能: 查看软件包详细信息"
            return 1
        fi

        # 确保bat命令可用
        local bat_cmd
        if command -v batcat >/dev/null 2>&1; then
            bat_cmd='batcat'
        elif command -v bat >/dev/null 2>&1; then
            bat_cmd='bat'
        else
            apt-cache show "$1"
            return
        fi

        apt-cache show "$1" | "$bat_cmd" -l yaml --paging=always
    }

    # APT别名
    alias as='apt-search'        # APT搜索
    alias ai='apt-installed'     # 已安装软件包
    alias ainfo='apt-info'       # 软件包信息
fi
