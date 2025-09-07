# fd (find的现代替代品) 配置

if command -v fd >/dev/null 2>&1; then
    # 基础搜索别名
    alias fdf='fd --type f'                    # 搜索文件
    alias fdd='fd --type d'                    # 搜索目录
    alias fda='fd --hidden --no-ignore'       # 搜索所有文件（包括隐藏）
    alias fdx='fd --type f --executable'      # 搜索可执行文件
    alias fds='fd --type s'                   # 搜索符号链接

    # fd + bat 集成：批量查看搜索结果
    if command -v bat >/dev/null 2>&1 || command -v batcat >/dev/null 2>&1; then
        # 搜索并用 bat 查看所有匹配的文件
        fdbat() {
            if [[ $# -eq 0 ]]; then
                echo "用法: fdbat <搜索模式> [路径]"
                echo "示例: fdbat '\\.py$' src/"
                return 1
            fi

            # 使用动态检测的bat命令
            if command -v batcat >/dev/null 2>&1; then
                fd "$@" --type f -X batcat
            elif command -v bat >/dev/null 2>&1; then
                fd "$@" --type f -X bat
            else
                fd "$@" --type f -X cat
            fi
        }

        # 搜索并预览文件内容
        fdpreview() {
            # 确保bat命令可用
            local bat_cmd
            if command -v batcat >/dev/null 2>&1; then
                bat_cmd='batcat'
            elif command -v bat >/dev/null 2>&1; then
                bat_cmd='bat'
            else
                echo "错误：未找到bat工具，请先安装"
                return 1
            fi

            if [[ $# -eq 0 ]]; then
                echo "用法: fdpreview <搜索模式> [路径]"
                return 1
            fi
            fd "$@" --type f -x "$bat_cmd" --color=always --style=header,grid --line-range=:50
        }
    fi
fi
