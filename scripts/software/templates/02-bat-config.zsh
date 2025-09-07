# bat (cat的增强版) 核心配置

if command -v bat >/dev/null 2>&1 || command -v batcat >/dev/null 2>&1; then
    # bat 环境变量配置
    export BAT_STYLE="numbers,changes,header,grid"
    export BAT_THEME="OneHalfDark"
    export BAT_PAGER="less -RFK"

    # 基础别名 - 使用动态检测的bat命令
    if command -v batcat >/dev/null 2>&1; then
        alias cat='batcat --paging=never'
        alias less='batcat --paging=always'
        alias more='batcat --paging=always'
        alias batl='batcat --paging=always'  # 强制分页
        alias batn='batcat --style=plain'    # 纯文本模式，无装饰
        alias batp='batcat --plain'          # 纯文本模式（简写）
    elif command -v bat >/dev/null 2>&1; then
        alias cat='bat --paging=never'
        alias less='bat --paging=always'
        alias more='bat --paging=always'
        alias batl='bat --paging=always'  # 强制分页
        alias batn='bat --style=plain'    # 纯文本模式，无装饰
        alias batp='bat --plain'          # 纯文本模式（简写）
    fi
fi
